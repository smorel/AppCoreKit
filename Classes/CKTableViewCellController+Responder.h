//
//  CKTableViewCellController+Responder.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"


/**
 */
@interface CKTableViewCellController(CKResponder)

///-----------------------------------
/// @name Managing UIResponder Chain
///-----------------------------------

/**
 */
- (BOOL)hasNextResponder;

/**
 */
- (BOOL)hasPreviousResponder;

/**
 */
- (BOOL)activateNextResponder;

/**
 */
- (BOOL)activatePreviousResponder;

/** If you override CKTableViewCellController, you should implement this method if you need integration with the responder chain.
 */
- (BOOL)hasResponder;

/** If you override CKTableViewCellController, you should implement this method if you need integration with the responder chain.
 */
- (void)becomeFirstResponder;

/** If you override CKTableViewCellController, you should implement this method if you need integration with the responder chain.
 */
- (UIView*)nextResponder:(UIView*)view;

@end
