//
//  CKTransitionViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-16.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewController.h"

@class CKTransitionViewController;

@protocol CKTransitionViewControllerDelegate <NSObject>

@optional

- (void)transitionViewController:(CKTransitionViewController *)transitionViewController willPresentViewController:(UIViewController *)viewController;
- (void)transitionViewController:(CKTransitionViewController *)transitionViewController didPresentViewController:(UIViewController *)viewController;

- (id <UIViewControllerAnimatedTransitioning>)transitionViewController:(CKTransitionViewController *)transitionViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end

/** A view controller that allows to present a child view controller with custom transitions when setting the new child view controller.
 */
@interface CKTransitionViewController : CKViewController

@property (nonatomic, assign) id<CKTransitionViewControllerDelegate> delegate;

@property (nonatomic, retain) UIViewController* viewController;

- (instancetype)initWithViewController:(UIViewController*)viewController;

@end
