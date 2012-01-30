//
//  CKNotificationBlockBinder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNotificationBlockBinder.h"
#import "CKBindingsManager.h"

@interface CKNotificationBlockBinder ()
#ifdef ENABLE_WEAK_REF_PROTECTION
@property (nonatomic, retain) CKWeakRef* instanceRef;
@property (nonatomic, retain) CKWeakRef* targetRef;
#endif
- (void)unbindInstance:(id)instance;
@end


@implementation CKNotificationBlockBinder

#ifdef ENABLE_WEAK_REF_PROTECTION
@synthesize instanceRef;
@synthesize targetRef;
#endif

@synthesize notificationName;
@synthesize block;
@synthesize selector;
@synthesize target;
@synthesize instance;

- (id)init{
	[super init];
	//NSLog(@"CKNotificationBlockBinder init %p",self);
	binded = NO;
#ifdef ENABLE_WEAK_REF_PROTECTION
    self.targetRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseTarget:)];
    self.instanceRef =  [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseInstance:)];
#endif
	return self;
}

- (void) dealloc{
	//NSLog(@"CKNotificationBlockBinder dealloc %p",self);
	[self unbind];
	[self reset];
#ifdef ENABLE_WEAK_REF_PROTECTION
    self.instanceRef = nil;
    self.targetRef = nil;
#endif
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKNotificationBlockBinder : %p>{\ninstanceRef = %@\nNotificationName = %@}",
			self,self.instance ? self.instance : @"(null)",notificationName];
}

- (void)reset{
    [super reset];
	self.instance = nil;
	self.target = nil;
	self.notificationName = nil;
	self.block = nil;
	self.selector = nil;
}

#ifdef ENABLE_WEAK_REF_PROTECTION
- (id)releaseTarget:(CKWeakRef*)weakRef{
    [self unbindInstance:weakRef.object];
    [[CKBindingsManager defaultManager]unregister:self];

	return nil;
}

- (void)setTarget:(id)theinstance{
	self.targetRef.object = theinstance;
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
    return self.instanceRef.object;
}
#endif

- (void)executeWithNotification:(NSNotification*)thenotification{
	if(block){
		block(thenotification);
	}
	else if(self.target && [self.target respondsToSelector:self.selector]){
		[self.target performSelector:self.selector withObject:thenotification];
	}
	else{
		//NSAssert(NO,@"CKNotificationBlockBinder no action plugged");
	}
}

- (void)onNotification:(NSNotification*)notification{
    if(self.contextOptions & CKBindingsContextPerformOnMainThread){
        [self performSelectorOnMainThread:@selector(executeWithNotification:) withObject:notification waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
    else {
        [self performSelector:@selector(executeWithNotification:) onThread:[NSThread currentThread] withObject:notification waitUntilDone:(self.contextOptions & CKBindingsContextWaitUntilDone)];
    }
}

- (void) bind{
	[self unbind];
	//NSLog(@"CKNotificationBlockBinder bind %p %@",self,notification);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:self.notificationName object:self.instance];
	binded = YES;
}

-(void)unbind{
	[self unbindInstance:self.instance];
}

- (void)unbindInstance:(id)theinstance{
	if(binded){
		//NSLog(@"CKNotificationBlockBinder unbind %p %@",self,notification);
		[[NSNotificationCenter defaultCenter] removeObserver:self name:self.notificationName object:theinstance];
		binded = NO;
	}
}

@end
