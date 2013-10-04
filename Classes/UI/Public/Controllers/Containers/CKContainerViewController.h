//
//  CKContainerViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKViewController.h"

/**
 */
typedef NS_ENUM(NSInteger, CKTransitionType){
    CKTransitionNone = UIViewAnimationOptionTransitionNone,
    CKTransitionFlipFromLeft    = UIViewAnimationOptionTransitionFlipFromLeft,
    CKTransitionFlipFromRight   = UIViewAnimationOptionTransitionFlipFromRight,
    CKTransitionCurlUp          = UIViewAnimationOptionTransitionCurlUp,
    CKTransitionCurlDown        = UIViewAnimationOptionTransitionCurlDown,
    CKTransitionCrossDissolve   = UIViewAnimationOptionTransitionCrossDissolve,
    CKTransitionFlipFromTop     = UIViewAnimationOptionTransitionFlipFromTop,
    CKTransitionFlipFromBottom  = UIViewAnimationOptionTransitionFlipFromBottom,
    CKTransitionPush            = 8 << 20,
    CKTransitionPop             = 9 << 20,
};

/**
 */
@interface CKContainerViewController : CKViewController

///-----------------------------------
/// @name Creating Container Controller Objects
///-----------------------------------

+ (id)controllerWithViewControllers:(NSArray *)viewControllers;

///-----------------------------------
/// @name Initializing Container Controller Objects
///-----------------------------------

/**
 */
- (id)initWithViewControllers:(NSArray *)viewControllers;

///-----------------------------------
/// @name Getting the Container View
///-----------------------------------

/**
 */
@property (nonatomic, retain, readonly) UIView *containerView;

///-----------------------------------
/// @name Accessing Container Controller attributes
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSArray* viewControllers;

/**
 */
@property (nonatomic, assign) NSUInteger selectedIndex;

/**
 */
@property (nonatomic, readonly) UIViewController* selectedViewController;

///-----------------------------------
/// @name Customizing the navigation bar content
///-----------------------------------

/**
 */
@property (nonatomic, assign, getter = doesPresentsSelectedViewControllerItemsInNavigationBar) BOOL presentsSelectedViewControllerItemsInNavigationBar;

/**
 */
@property (nonatomic, assign, getter = doesPresentsSelectedViewControllerItemsInToolbar) BOOL presentsSelectedViewControllerItemsInToolbar;


///-----------------------------------
/// @name Presenting view controllers
///-----------------------------------

/**
 */
- (void)presentViewControllerAtIndex:(NSUInteger)index withTransition:(CKTransitionType)transition;

@end


/**
 */
@interface UIViewController (CKContainerViewController)

///-----------------------------------
/// @name Accessing the Container Controller=
///-----------------------------------

/**
 */
@property (nonatomic,assign) UIViewController *containerViewController;

@end
