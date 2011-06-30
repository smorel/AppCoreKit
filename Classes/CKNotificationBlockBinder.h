//
//  CKNotificationBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"
#import "CKWeakRef.h"

typedef void(^CKNotificationExecutionBlock)(NSNotification* notification);


/** TODO
 */
@interface CKNotificationBlockBinder : NSObject<CKBinding> {
	CKWeakRef* instanceRef;
	NSString* notificationName;
	
	//We can use block or target/selector
	CKNotificationExecutionBlock block;
	CKWeakRef* targetRef;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, copy)   CKNotificationExecutionBlock block;
@property (nonatomic, assign) SEL selector;


- (void)setTarget:(id)instance;
- (void)setInstance:(id)instance;

@end
