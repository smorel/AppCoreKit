//
//  CKUIControlBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"
#import "CKWeakRef.h"

typedef void(^CKUIControlBlock)();

/** TODO
 */
@interface CKUIControlBlockBinder : NSObject<CKBinding>{
	UIControlEvents controlEvents;
	
	//We can use block or target/selector
	CKUIControlBlock block;
	CKWeakRef* targetRef;
	SEL selector;
	
	CKWeakRef* controlRef;
	BOOL binded;
}

@property (nonatomic, assign) UIControlEvents controlEvents;
@property (nonatomic, copy) CKUIControlBlock block;
@property (nonatomic, assign) SEL selector;

- (void)setTarget:(id)instance;
- (void)setControl:(UIControl*)control;

@end
