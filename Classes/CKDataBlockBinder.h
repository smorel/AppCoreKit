//
//  CKDataBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-17.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"

typedef void(^CKDataBlockBinderExecutionBlock)(id value);
@interface CKDataBlockBinder : NSObject<CKBinding> {
	id instance;
	NSString* keyPath;
	
	//We can use block or target/selector
	CKDataBlockBinderExecutionBlock block;
	id target;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, assign) id instance;
@property (nonatomic, retain) NSString* keyPath;
@property (nonatomic, copy)   CKDataBlockBinderExecutionBlock block;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end
