//
//  CKBreadCrumbViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-25.
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

