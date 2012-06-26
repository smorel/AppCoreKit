//
//  CKDataBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-17.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"
#import "CKWeakRef.h"

typedef void(^CKDataBlockBinderExecutionBlock)(id value);


/**
 */
@interface CKDataBlockBinder : CKBinding {
	NSString* keyPath;
	
	//We can use block or target/selector
	CKDataBlockBinderExecutionBlock block;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, retain) NSString* keyPath;
@property (nonatomic, copy)   CKDataBlockBinderExecutionBlock block;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) id instance;
@property (nonatomic, assign) id target;

@end
