//
//  CKCollectionCellContentViewController+ResponderChain.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

@interface CKCollectionCellContentViewController (ResponderChain)


///-----------------------------------
/// @name Managing UIResponder Chain
///-----------------------------------

/**
*/
@property(nonatomic,assign,readonly) BOOL isFirstResponder;

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

/** 
 */
- (BOOL)hasResponder;

/**
 */
- (UIView*)nextResponder:(UIView*)view;

/**
 */
- (void)becomeFirstResponder;

/**
 */
- (void)resignFirstResponder;

@end
