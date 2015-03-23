//
//  CKReusableViewController+ResponderChain.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-04.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController.h"

@interface CKReusableViewController (ResponderChain)


///-----------------------------------
/// @name Managing UIResponder Chain
///-----------------------------------

- (BOOL)isFirstResponder;

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


/**
 */
- (void)didBecomeFirstResponder;

/**
 */
- (void)didResignFirstResponder;

@end
