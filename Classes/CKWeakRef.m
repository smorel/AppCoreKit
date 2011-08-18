//
//  CKWeakRef.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKWeakRef.h"
#import <objc/runtime.h>

static char NSObjectWeakRefObjectKey;

//CKWeakRefAssociatedObject

@interface CKWeakRefAssociatedObject : NSObject{
	NSMutableSet* _weakRefs;
}
@property(nonatomic,retain)NSMutableSet* weakRefs;
- (void)registerWeakRef:(CKWeakRef*)ref;
- (void)unregisterWeakRef:(CKWeakRef*)ref;
@end

//CKWeakRef PRIVATE

@interface CKWeakRef ()
@property(nonatomic,retain)CKCallback* callback;
- (CKWeakRefAssociatedObject*)setupAssociatedObject;
@end


//CKWeakRefAssociatedObject

@implementation CKWeakRefAssociatedObject
@synthesize weakRefs = _weakRefs;

- (id)init{
	[super init];
	self.weakRefs = [NSMutableSet set];
	return self;
}

- (void)dealloc{
	[_weakRefs release];
	_weakRefs = nil;
	[super dealloc];
}

- (void)registerWeakRef:(CKWeakRef*)ref{
	[_weakRefs addObject:[NSValue valueWithNonretainedObject:ref]];
}

- (void)unregisterWeakRef:(CKWeakRef*)ref{
	[_weakRefs removeObject:[NSValue valueWithNonretainedObject:ref]];
}

@end


//NSObject (CKWeakRefAdditions)


@interface NSObject (CKWeakRefAdditions)
@property (nonatomic,retain)CKWeakRefAssociatedObject* weakRefObject;
@end


@implementation NSObject (CKWeakRefAdditions)

- (void)setWeakRefObject:(CKWeakRefAssociatedObject *)object {
    objc_setAssociatedObject(self, 
                             &NSObjectWeakRefObjectKey,
                             object,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKWeakRefAssociatedObject *)weakRefObject {
    return objc_getAssociatedObject(self, &NSObjectWeakRefObjectKey);
}

- (void) weakRef_dealloc {
	CKWeakRefAssociatedObject* weakRefObj = [self weakRefObject];
	if(weakRefObj){
		while([weakRefObj.weakRefs count] > 0){
			NSValue* refValue = [weakRefObj.weakRefs anyObject];
			CKWeakRef* ref = [[refValue nonretainedObjectValue]retain];
			if(ref.callback){
				[ref.callback execute:ref];
			}
			
			ref.object = nil;//this will call unregister ...
			[ref release];
		}
		
		objc_setAssociatedObject(self, 
								 &NSObjectWeakRefObjectKey,
								 nil,
								 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	[self weakRef_dealloc];
}

@end

//CKWeakRef

@interface CKWeakRef ()
- (void)registerToObject:(id)object;
- (void)unregisterToObject:(id)object;
@end

static BOOL swizzlingDone = NO;

@implementation CKWeakRef
@synthesize object = _object;
@synthesize callback = _callback;

+ (void)executeSwizzling{
    if(!swizzlingDone){
        Method origMethod = class_getInstanceMethod([NSObject class], @selector(dealloc));
        Method newMethod = class_getInstanceMethod([NSObject class], @selector(weakRef_dealloc));
        if (class_addMethod([NSObject class], @selector(dealloc), method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod([NSObject class], @selector(weakRef_dealloc), method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        }
        else {
            method_exchangeImplementations(origMethod, newMethod);
        }
        swizzlingDone = YES;
    }
}

+ (void)load{
	[self executeSwizzling];
}

- (void)dealloc{
    [self unregisterToObject:_object];
	
	_object = nil;
	[_callback release];
	_callback = nil;
	[super dealloc];
}

- (id)initWithObject:(id)theObject{
	[[self class] executeSwizzling];
	[super init];
	self.object = theObject;
	[self registerToObject:theObject];
	return self;
}

- (id)initWithObject:(id)theObject callback:(CKCallback*)callback{
	[[self class] executeSwizzling];
	[super init];
	self.object = theObject;
	self.callback = callback;
	[self registerToObject:theObject];
	return self;
}

- (id)initWithObject:(id)object block:(void (^)(id object))block{
	[self initWithObject:object callback:[CKCallback callbackWithBlock:^(id object){
		block(object);
		return (id)nil;
	}]];
	return self;
}

- (id)initWithObject:(id)object target:(id)target action:(SEL)action{
	[self initWithObject:object callback:[CKCallback callbackWithTarget:target action:action]];
	return self;
}


- (void)registerToObject:(id)theobject{
    if(theobject){
        CKWeakRefAssociatedObject* targetWeakRefObject = [theobject weakRefObject];
        if(targetWeakRefObject == nil){
            targetWeakRefObject = [[[CKWeakRefAssociatedObject alloc]init]autorelease];
            [theobject setWeakRefObject:targetWeakRefObject];
        }
        [targetWeakRefObject registerWeakRef:self];
    }
}

- (void)unregisterToObject:(id)theobject{
    if(theobject){
		CKWeakRefAssociatedObject* targetWeakRefObject = [theobject weakRefObject];
		if(targetWeakRefObject){
			[targetWeakRefObject unregisterWeakRef:self];
		}
	}
}

- (void)setObject:(id)theobject{
    [self unregisterToObject:_object];
    _object = theobject;
    [self registerToObject:_object];
}

+ (CKWeakRef*)weakRefWithObject:(id)object{
	return [[[CKWeakRef alloc]initWithObject:object]autorelease];
}

+ (CKWeakRef*)weakRefWithObject:(id)object callback:(CKCallback*)callback{
	return [[[CKWeakRef alloc]initWithObject:object callback:callback]autorelease];
}

+ (CKWeakRef*)weakRefWithObject:(id)object block:(void (^)(id object))block{
	return [[[CKWeakRef alloc]initWithObject:object block:block]autorelease];
}
+ (CKWeakRef*)weakRefWithObject:(id)object target:(id)target action:(SEL)action{
	return [[[CKWeakRef alloc]initWithObject:object target:target action:action]autorelease];
}

@end
