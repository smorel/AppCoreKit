//
//  NSObject+Notifications.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "NSObject+Notifications.h"

@implementation NSObject (CKNSObjectNotifications)

- (void)observeNotificationName:(NSString *)name selector:(SEL)selector { 
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:selector
												 name:name
											   object:nil];	
}

- (void)unobserveNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)postNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self 
													  userInfo:userInfo];
}

@end
