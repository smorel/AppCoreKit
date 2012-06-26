//
//  CKBinding.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CKNSObject+Bindings.h"
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
