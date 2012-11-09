//
//  CKNotificationBlockBinder.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"
#import "CKWeakRef.h"

typedef void(^CKNotificationExecutionBlock)(NSNotification* notification);


/**
 */
@interface CKNotificationBlockBinder : CKBinding {
	NSString* notificationName;
	
	//We can use block or target/selector
	CKNotificationExecutionBlock block;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, copy)   CKNotificationExecutionBlock block;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) id instance;
@property (nonatomic, assign) id target;


@end
