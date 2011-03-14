//
//  CKBindingsManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBindingsManager.h"
#import "CKBinding.h"
#import <objc/runtime.h>

@interface CKBindingsManager ()
@property (nonatomic, retain) NSDictionary *bindingsPoolForClass;
@property (nonatomic, retain) NSDictionary *bindingsForContext;
@property (nonatomic, retain) NSDictionary *bindingsToContext;
@property (nonatomic, retain) NSMutableSet *contexts;
@end

static CKBindingsManager* CKBindingsDefauktManager = nil;
@implementation CKBindingsManager
@synthesize bindingsForContext = _bindingsForContext;
@synthesize bindingsPoolForClass = _bindingsPoolForClass;
@synthesize bindingsToContext = _bindingsToContext;
@synthesize contexts = _contexts;

- (id)init{
	[super init];
	self.bindingsForContext = [NSMutableDictionary dictionary];
	self.bindingsToContext = [NSMutableDictionary dictionary];
	self.bindingsPoolForClass = [NSMutableDictionary dictionary];
	self.contexts = [NSMutableSet set];
	return self;
}

- (void)dealloc{
	[_bindingsForContext release];
	[_bindingsPoolForClass release];
	[_bindingsToContext release];
	[_contexts release];
	[super dealloc];
}

+ (CKBindingsManager*)defaultManager{
	if(CKBindingsDefauktManager == nil){
		CKBindingsDefauktManager = [[CKBindingsManager alloc]init];
	}
	return CKBindingsDefauktManager;
}

- (NSString*)description{
	return [_bindingsForContext description];
}

//The client should release the object returned !
- (id)dequeueReusableBindingWithClass:(Class)bindingClass{
	NSString* className = [NSString stringWithUTF8String:class_getName(bindingClass)];
	NSMutableArray* bindings = [_bindingsPoolForClass valueForKey:className];
	if(!bindings){
		bindings = [NSMutableArray array];
		[_bindingsPoolForClass setValue:bindings forKey:className];
	}
	
	if([bindings count] > 0){
		id binding = [[bindings lastObject]retain];
		[bindings removeLastObject];
		return binding;
	}
	
	return [[bindingClass alloc]init];
}

- (void)bind:(id)binding withContext:(id)context{
	if([binding conformsToProtocol:@protocol(CKBinding)]){
		[binding performSelector:@selector(bind)];
	}
	
	NSMutableArray* bindings = [_bindingsForContext objectForKey:[NSValue valueWithNonretainedObject:context]];
	if(!bindings){
		[_contexts addObject:[NSValue valueWithNonretainedObject:context]];
		bindings = [NSMutableArray array];
		[_bindingsForContext setObject:bindings forKey:[NSValue valueWithNonretainedObject:context]];
	}
	[bindings addObject:binding];
	[_bindingsToContext setObject:context forKey:[NSValue valueWithNonretainedObject:binding]];
}


- (void)unregister:(id)binding{
	id context = [_bindingsToContext objectForKey:[NSValue valueWithNonretainedObject:binding]];
	
	NSMutableArray* bindings = [_bindingsForContext objectForKey:[NSValue valueWithNonretainedObject:context]];
	if(!bindings){
		NSAssert(NO,@"Should not unbind a non binded item");
		return;
	}
	
	//Put the binding in the reusable queue
	NSString* className = [NSString stringWithUTF8String:class_getName([binding class])];
	NSMutableArray* queuedBindings = [_bindingsPoolForClass valueForKey:className];
	if(!queuedBindings){
		queuedBindings = [NSMutableArray array];
		[_bindingsPoolForClass setValue:queuedBindings forKey:className];
	}
	[queuedBindings addObject:binding];
	[_bindingsToContext removeObjectForKey:[NSValue valueWithNonretainedObject:binding]];
	
	if([bindings count] <= 0){
		[_bindingsForContext removeObjectForKey:[NSValue valueWithNonretainedObject:context]];
		[_contexts removeObject:context];
	}	
	[bindings removeObject:binding];
}

- (void)unbind:(id)binding{
	if([binding conformsToProtocol:@protocol(CKBinding)]){
		[binding performSelector:@selector(unbind)];
	}
	[self unregister:binding];
}

- (void)unbindAllBindingsWithContext:(id)context{
	NSMutableArray* bindings = [_bindingsForContext objectForKey:[NSValue valueWithNonretainedObject:context]];
	if(!bindings){
		return;
	}
	
	for(id binding in bindings){
		if([binding conformsToProtocol:@protocol(CKBinding)]){
			[binding performSelector:@selector(unbind)];
		}
		
		NSString* className = [NSString stringWithUTF8String:class_getName([binding class])];
		NSMutableArray* queuedBindings = [_bindingsPoolForClass valueForKey:className];
		if(!queuedBindings){
			queuedBindings = [NSMutableArray array];
			[_bindingsPoolForClass setValue:queuedBindings forKey:className];
		}
		[queuedBindings addObject:binding];
		[_bindingsToContext removeObjectForKey:[NSValue valueWithNonretainedObject:binding]];
	}
	
	[_bindingsForContext removeObjectForKey:[NSValue valueWithNonretainedObject:context]];
	[_contexts removeObject:context];
}

@end
