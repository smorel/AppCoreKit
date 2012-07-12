//
//  CKDataBlockBinder.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDataBlockBinder.h"
#import "NSObject+Runtime.h"
#import "CKBindingsManager.h"

@interface CKDataBlockBinder ()
#ifdef ENABLE_WEAK_REF_PROTECTION
@property (nonatomic, retain) CKWeakRef* instanceRef;
@property (nonatomic, retain) CKWeakRef* targetRef;
#endif
- (void)unbindInstance:(id)instance;
@end

@implementation CKDataBlockBinder

#ifdef ENABLE_WEAK_REF_PROTECTION
@synthesize instanceRef;
@synthesize targetRef;
#endif
@synthesize keyPath;
@synthesize block;
@synthesize selector;
@synthesize target;
@synthesize instance;

- (id)init{
	if (self = [super init]) {
        binded = NO;
#ifdef ENABLE_WEAK_REF_PROTECTION
        self.targetRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseTarget:)];
        self.instanceRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseInstance:)];
#endif
    }
	return self;
}

- (void) dealloc{
	[self unbind];
	[self reset];
#ifdef ENABLE_WEAK_REF_PROTECTION
    self.instanceRef = nil;
    self.targetRef = nil;
#endif
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKDataBlockBinder : %p>{\ninstance = %@\nkeyPath = %@}",
			self,instance ? instance : @"(null)",keyPath];
}

- (void)reset{
    [super reset];
    
	self.instance = nil;
	self.target = nil;
	self.keyPath = nil;
	self.block = nil;
	self.selector = nil;
}

#ifdef ENABLE_WEAK_REF_PROTECTION
- (id)releaseTarget:(CKWeakRef*)weakRef{
    [self unbindInstance:self.instance];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setTarget:(id)theTarget{
    self.targetRef.object = theTarget;
}

- (id)target{
    return self.targetRef.object;
}

- (id)releaseInstance:(CKWeakRef*)weakRef{
    [self unbindInstance:weakRef.object];
    [[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setInstance:(id)theinstance{
    self.instanceRef.object = theinstance;
}

- (id)instance{
    return  self.instanceRef.object;
}

#endif

- (void)executeWithValue:(id)value{
    if(block){
		block(value);
	}
	else if(self.target && [self.target respondsToSelector:self.selector]){
		[self.target performSelector:self.selector withObject:value];
	}
	else{
		//NSAssert(NO,@"CKDataBlockBinder no action plugged");
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self performSelectorOnMainThread:@selector(executeWithValue:) withObject:newValue waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(executeWithValue:) onThread:[NSThread currentThread] withObject:newValue waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
}


- (void) bind{
	[self unbind];
	if(self.instance){
		[self.instance addObserver:self
                        forKeyPath:self.keyPath
                           options:(NSKeyValueObservingOptionNew)
                           context:nil];
		binded = YES;
	}
}

-(void)unbind{
	[self unbindInstance:self.instance];
}

- (void)unbindInstance:(id)theinstance{
	if(binded){
		[theinstance removeObserver:self
                         forKeyPath:self.keyPath];
		binded = NO;
	}
}

@end