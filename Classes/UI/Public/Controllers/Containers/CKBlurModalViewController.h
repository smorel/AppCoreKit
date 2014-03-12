//
//  CKBlurModalViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/26/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKViewController.h"


/**
 */
@interface CKBlurModalViewController : CKViewController

/** Default value is 0.3
 */
@property(nonatomic,assign) NSTimeInterval animationDuration;

/** Defines the maximum blur at the end of the appear animation. This calur will be interpolated between 0 and the sepecified blurRadius during the animation.
 Default value is 2.0
 */
@property(nonatomic,assign) CGFloat blurRadius;

/** Defines the tint color that will be blended on top of the blurred image. The tint color alpha be interpolated from 0 to the alpha specified in blurTintColor during the animation.
 Default value is black with alpha 0.5
 */
@property(nonatomic,retain) UIColor* blurTintColor;

/** Default value is 1.0
 */
@property(nonatomic,assign) CGFloat saturationDelta;

/** Defines the scale applied to the blurred screen image. This will be interpolated betwwen (1,1) and (backgroundScale,backgroundScale) during the animation.
 Default value is 0.9
 */
@property(nonatomic,assign) CGFloat backgroundScale;

/** Defines the animation for hiding/showing status bar.
 Default value is UIStatusBarAnimationFade
 */
@property(nonatomic,assign) UIStatusBarAnimation statusBarAnimation;

/**
 */
- (id)initWithContentViewController:(UIViewController*)contentViewController;

/**
 */
- (void)presentFromViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void(^)())completion;

/**
 */
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;

@end
