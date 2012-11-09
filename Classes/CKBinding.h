//
//  CKBinding.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NSObject+Bindings.h"
#import "CKWeakRef.h"

#define ENABLE_WEAK_REF_PROTECTION

/** 
 */
@interface CKBinding : NSObject

///-----------------------------------
/// @name Managing the context
///-----------------------------------

/**
 */
@property(nonatomic,assign)   id context;

/**
 */
@property(nonatomic,assign)   CKBindingsContextOptions contextOptions;

///-----------------------------------
/// @name Executing the binding
///-----------------------------------

/**
 */
- (void)bind;

/**
 */
- (void)unbind;

///-----------------------------------
/// @name Reusing the binding
///-----------------------------------

/**
 */
- (void)reset;

@end
