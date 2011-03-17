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
@property (nonatomic, retain) MAZeroingWeakRef* instanceRef;
@property (nonatomic, retain) MAZeroingWeakRef* targetRef;
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
	
	return self;
}

- (void) dealloc{
	//NSLog(@"CKNotificationBlockBinder dealloc %p",self);
	[self unbind];
	[self reset];
	[super dealloc];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"<CKNotificationBlockBinder : %p>{\ninstanceRef = %@\nNotificationName = %@}",
			self,instanceRef ? instanceRef.target : @"(null)",notificationName];
}

- (void)reset{
	self.instanceRef = nil;
	self.notificationName = nil;
	self.block = nil;
	self.targetRef = nil;
	self.selector = nil;
}

- (void)setTarget:(id)instance{
	if(instance){
		self.targetRef = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		__block CKNotificationBlockBinder* bself = self;
		[targetRef setCleanupBlock: ^(id target) {
			[self unbindInstance:instanceRef.target];
			[[CKBindingsManager defaultManager]unregister:bself];
		}];
	}
	else{
		self.targetRef = nil;
	}
}

- (void)setInstance:(id)instance{
	if(instance){
		self.instanceRef = [[[MAZeroingWeakRef alloc] initWithTarget:instance]autorelease];
		__block CKNotificationBlockBinder* bself = self;
		[instanceRef setCleanupBlock: ^(id target) {
			[self unbindInstance:target];
			[[CKBindingsManager defaultManager]unregister:bself];
		}];
	}
	else {
		self.instanceRef = nil;
	}
}

- (void)onNotification:(NSNotification*)notification{
	if(block){
		block(notification);
	}
	else if(targetRef.target && [targetRef.target respondsToSelector:self.selector]){
		[targetRef.target performSelector:self.selector withObject:notification];
	}
	else{
		NSAssert(NO,@"CKNotificationBlockBinder no action plugged");
	}
}

- (void) bind{
	[self unbind];
	//NSLog(@"CKNotificationBlockBinder bind %p %@",self,notification);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:notificationName object:instanceRef.target];
	binded = YES;
}

-(void)unbind{
	[self unbindInstance:instanceRef.target];
}

- (void)unbindInstance:(id)instance{
	if(binded){
		//NSLog(@"CKNotificationBlockBinder unbind %p %@",self,notification);
		[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:instance];
		binded = NO;
	}
}

@end
