//
//  CKNotificationBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"
#import "MAZeroingWeakRef.h"

typedef void(^CKNotificationExecutionBlock)(NSNotification* notification);

@interface CKNotificationBlockBinder : NSObject<CKBinding> {
	MAZeroingWeakRef* instanceRef;
	NSString* notificationName;
	
	//We can use block or target/selector
	CKNotificationExecutionBlock block;
	MAZeroingWeakRef* targetRef;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, copy)   CKNotificationExecutionBlock block;
@property (nonatomic, assign) SEL selector;


- (void)setTarget:(id)instance;
- (void)setInstance:(id)instance;

@end
