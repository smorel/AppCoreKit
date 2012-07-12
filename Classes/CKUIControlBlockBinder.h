//
//  CKUIControlBlockBinder.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"
#import "CKWeakRef.h"

typedef void(^CKUIControlBlock)();

/**
 */
@interface CKUIControlBlockBinder : CKBinding{
	UIControlEvents controlEvents;
	
	//We can use block or target/selector
	CKUIControlBlock block;
	SEL selector;
	
	BOOL binded;
}

@property (nonatomic, assign) UIControlEvents controlEvents;
@property (nonatomic, copy) CKUIControlBlock block;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) id control;
@property (nonatomic, assign) id target;

@end
