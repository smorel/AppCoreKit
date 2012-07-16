//
//  CKNSObject+Notifications.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSObject (CKNSObjectNotifications)

- (void)observeNotificationName:(NSString *)name selector:(SEL)selector;
- (void)unobserveNotifications;
- (void)postNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo;

@end
