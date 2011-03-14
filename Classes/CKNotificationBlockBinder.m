//
//  CKNotificationBlockBinder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNotificationBlockBinder.h"
#import "CKBindingsManager.h"


@implementation CKNotificationBlockBinder

@synthesize instance;
@synthesize notificationName;
@synthesize block;
@synthesize target;
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
	self.instance = nil;
	self.notificationName = nil;
	self.block = nil;
	self.target = nil;
	self.selector = nil;
	[super dealloc];
}

- (void)onNotification:(NSNotification*)notification{
	if(block){
		block(notification);
	}
	else if(target && [target respondsToSelector:self.selector]){
		[target performSelector:self.selector withObject:notification];
	}
	else{
		NSAssert(NO,@"CKNotificationBlockBinder no action plugged");
	}
}

- (void) bind{
	[self unbind];
	//NSLog(@"CKNotificationBlockBinder bind %p %@",self,notification);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:notificationName object:instance];
	binded = YES;
}

-(void)unbind{
	if(binded){
		//NSLog(@"CKNotificationBlockBinder unbind %p %@",self,notification);
		[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:instance];
		[[CKBindingsManager defaultManager]unbind:self];
		binded = NO;
	}
}

@end
