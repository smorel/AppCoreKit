//
//  NSObject+Notifications.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSObject (CKNSObjectNotifications)

///-----------------------------------
/// @name Managing Notification Observers
///-----------------------------------

/** Returns true is an object of the array validate the given predicate
 */
- (void)observeNotificationName:(NSString *)name selector:(SEL)selector;

/** 
 */
- (void)unobserveNotifications;

///-----------------------------------
/// @name Posting Notifications
///-----------------------------------

/** 
 */
- (void)postNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo;

@end
