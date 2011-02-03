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

- (void) dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:target];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:notification object:target];
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
