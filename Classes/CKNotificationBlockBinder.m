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
@property (nonatomic, retain) CKWeakRef* instanceRef;
@property (nonatomic, retain) CKWeakRef* targetRef;
- (void)unbindInstance:(id)instance;
@end


@implementation CKNotificationBlockBinder

@synthesize instanceRef;
@synthesize notificationName;
@synthesize block;
@synthesize targetRef;
@synthesize selector;

- (id)init{
	[super init];
	//NSLog(@"CKNotificationBlockBinder init %p",self);
	binded = NO;
    self.targetRef = [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseTarget:)];
    self.instanceRef =  [CKWeakRef weakRefWithObject:nil target:self action:@selector(releaseInstance:)];
	return self;
}

- (void) dealloc{
	//NSLog(@"CKNotificationBlockBinder dealloc %p",self);
	[self unbind];
	[self reset];
    self.instanceRef = nil;
    self.targetRef = nil;
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKNotificationBlockBinder : %p>{\ninstanceRef = %@\nNotificationName = %@}",
			self,instanceRef ? instanceRef.object : @"(null)",notificationName];
}

- (void)reset{
    [super reset];
	self.instanceRef.object = nil;
	self.notificationName = nil;
	self.block = nil;
	self.targetRef.object = nil;
	self.selector = nil;
}

- (id)releaseTarget:(CKWeakRef*)weakRef{
	[self unbindInstance:weakRef.object];
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setTarget:(id)instance{
	self.targetRef.object = instance;
}

- (id)releaseInstance:(CKWeakRef*)weakRef{
	[self unbindInstance:weakRef.object];
	[[CKBindingsManager defaultManager]unregister:self];
	return nil;
}

- (void)setInstance:(id)instance{
	self.instanceRef.object = instance;
}


- (void)executeWithNotification:(NSNotification*)notification{
	if(block){
		block(notification);
	}
	else if(targetRef.object && [targetRef.object respondsToSelector:self.selector]){
		[targetRef.object performSelector:self.selector withObject:notification];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:notificationName object:instanceRef.object];
	binded = YES;
}

-(void)unbind{
	[self unbindInstance:instanceRef.object];
}

- (void)unbindInstance:(id)instance{
	if(binded){
		//NSLog(@"CKNotificationBlockBinder unbind %p %@",self,notification);
		[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:instance];
		binded = NO;
	}
}

@end
