//
//  CKNotificationBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"

typedef void(^CKNotificationExecutionBlock)(NSNotification* notification);

@interface CKNotificationBlockBinder : NSObject<CKBinding> {
	id instance;
	NSString* notificationName;
	
	//We can use block or target/selector
	CKNotificationExecutionBlock block;
	id target;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, assign) id instance;
@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, copy)   CKNotificationExecutionBlock block;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end
