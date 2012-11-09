//
//  CKBreadCrumbViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKTabViewController.h"

/**
 */
@interface CKBreadCrumbViewController : CKTabViewController

///-----------------------------------
/// @name Pushing and Popping Stack Items
///-----------------------------------

/**
 */
- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated;

/**
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;

@end

