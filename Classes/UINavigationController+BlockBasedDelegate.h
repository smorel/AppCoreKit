//
//  UINavigationController+BlockBasedDelegate.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UINavigationControllerBlock)(UINavigationController* navigationController,UIViewController* controller, BOOL animated);


/**
 */
@interface UINavigationController (CKBlockBasedDelegate)<UINavigationControllerDelegate>

///-----------------------------------
/// @name Creating UINavigationController objects
///-----------------------------------

/** Returns an autoreleased UINavigationController object.
 */
+ (UINavigationController*)navigationControllerWithRootViewController:(UIViewController*)rootViewController;

///-----------------------------------
/// @name Reacting to UINavigationController events
///-----------------------------------

/**
 */
@property(nonatomic,copy) UINavigationControllerBlock didPushViewControllerBlock;

/**
 */
@property(nonatomic,copy) UINavigationControllerBlock didPopViewControllerBlock;

/**
 */
@property(nonatomic,copy) UINavigationControllerBlock willPushViewControllerBlock;

/**
 */
@property(nonatomic,copy) UINavigationControllerBlock willPopViewControllerBlock;

@end
