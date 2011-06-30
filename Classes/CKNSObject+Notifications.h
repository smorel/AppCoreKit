//
//  CKNSObject+Notifications.h
//  CloudKit
//
//  Created by Fred Brunel on 10-12-21.
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
