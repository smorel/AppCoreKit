//
//  CKNotificationBlockBinder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNotificationBlockBinder.h"


@implementation CKNotificationBlockBinder

@synthesize target;
@synthesize notification;
@synthesize executionBlock;

- (id)init{
	[super init];
	//NSLog(@"CKNotificationBlockBinder init %p",self);
	binded = NO;
	return self;
}

- (void) dealloc{
	//NSLog(@"CKNotificationBlockBinder dealloc %p",self);
	[self unbind];
	self.target = nil;
	self.notification = nil;
	self.executionBlock = nil;
	[super dealloc];
}

- (void)onNotification:(NSNotification*)notification{
	if(executionBlock){
		executionBlock();
	}
}

- (void) bind{
	[self unbind];
	//NSLog(@"CKNotificationBlockBinder bind %p %@",self,notification);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:notification object:target];
	binded = YES;
}

-(void)unbind{
	if(binded){
		//NSLog(@"CKNotificationBlockBinder unbind %p %@",self,notification);
		[[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:target];
		binded = NO;
	}
}

+(CKNotificationBlockBinder*) notificationBlockBinder:(id)target notification:(NSString*)notification executionBlock:(CKNotificationExecutionBlock)executionBlock{
	CKNotificationBlockBinder* binder = [[[CKNotificationBlockBinder alloc]init]autorelease];
	binder.target = target;
	binder.notification = notification;
	binder.executionBlock = executionBlock;
	[binder bind];
	return binder;
}


@end
