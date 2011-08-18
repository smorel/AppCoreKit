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


/** TODO
 */
@interface CKDataBlockBinder : CKBinding {
	CKWeakRef* instanceRef;
	NSString* keyPath;
	
	//We can use block or target/selector
	CKDataBlockBinderExecutionBlock block;
	CKWeakRef* targetRef;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, retain) NSString* keyPath;
@property (nonatomic, copy)   CKDataBlockBinderExecutionBlock block;
@property (nonatomic, assign) SEL selector;

- (void)setTarget:(id)instance;
- (void)setInstance:(id)instance;

@end
