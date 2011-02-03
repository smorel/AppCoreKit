//
//  CKNotificationBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

typedef void(^CKNotificationExecutionBlock)();

@interface CKNotificationBlockBinder : NSObject {
	id target;
	NSString* notification;
	CKNotificationExecutionBlock executionBlock;
}

@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSString* notification;
@property (nonatomic, retain) CKNotificationExecutionBlock executionBlock;

+(CKNotificationBlockBinder*) notificationBlockBinder:(id)target notification:(NSString*)notification executionBlock:(CKNotificationExecutionBlock)executionBlock;
- (void) bind;

@end
