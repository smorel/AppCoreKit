//
//  CKSplitViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "CKObject.h"


/**
 */
typedef NS_ENUM(NSInteger, CKSplitViewOrientation){
    CKSplitViewOrientationHorizontal,
    CKSplitViewOrientationVertical
};


//CKSplitViewController

/**
 */
@interface CKSplitViewController : CKViewController


///-----------------------------------
/// @name Creating SplitViewController objects
///-----------------------------------

/**
 */
+ (CKSplitViewController*)splitViewControllerWithOrientation:(CKSplitViewOrientation)orientation;

/**
 */
+ (CKSplitViewController*)splitViewControllerWithViewControllers:(NSArray*)viewControllers;

/**
 */
+ (CKSplitViewController*)splitViewControllerWithViewControllers:(NSArray*)viewControllers orientation:(CKSplitViewOrientation)orientation;

///-----------------------------------
/// @name Initializing SplitViewController Objects
///-----------------------------------

/**
 */
- (id)initWithViewControllers:(NSArray*)viewControllers;

/**
 */
- (id)initWithViewControllers:(NSArray*)viewControllers orientation:(CKSplitViewOrientation)orientation;


///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property(nonatomic,assign)CKSplitViewOrientation orientation;

/** default value is YES. Set this value to YES if you want the split view controllers to start layouting beside the navigation bar taking care of transparency when the split view controller is in a navigation controller.
 */
@property(nonatomic,assign) BOOL automaticallyAdjustInsetsToMatchNavigationControllerTransparency;


///-----------------------------------
/// @name Managing the view controllers
///-----------------------------------

/**
 */
@property (nonatomic, copy) NSArray* viewControllers;


@end
