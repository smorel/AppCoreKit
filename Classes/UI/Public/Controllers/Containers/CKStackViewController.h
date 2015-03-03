//
//  CKStackViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-29.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKViewController.h"

/**
 */
@interface CKStackViewController : CKViewController

///-----------------------------------
/// @name Creating SplitViewController objects
///-----------------------------------

/**
 */
+ (CKStackViewController*)stackViewControllerWithViewControllers:(NSArray*)viewControllers;


///-----------------------------------
/// @name Initializing StackViewController Objects
///-----------------------------------

/**
 */
- (id)initWithViewControllers:(NSArray*)viewControllers;

///-----------------------------------
/// @name Managing the view controllers
///-----------------------------------

/**
 */
@property (nonatomic, copy) NSArray* viewControllers;

@end
