//
//  CKSplitViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "CKObject.h"

//CKSplitViewConstraints


typedef enum CKSplitViewConstraintsType{
    CKSplitViewConstraintsTypeFlexibleSize,
    CKSplitViewConstraintsTypeFixedSizeInPixels,
    CKSplitViewConstraintsTypeFixedSizeRatio
}CKSplitViewConstraintsType;

/**
 */
@interface CKSplitViewConstraints : CKObject

///-----------------------------------
/// @name Creating SplitView Constraints Object
///-----------------------------------

/**
 */
+ (CKSplitViewConstraints*)constraints;

///-----------------------------------
/// @name Configuring the constraint
///-----------------------------------

/**
 */
@property(nonatomic,assign)CKSplitViewConstraintsType type;

/** in pixel or ratio depending on the specified type
 */
@property(nonatomic,assign)CGFloat size;

@end




@class CKSplitView;

/**
 */
@protocol CKSplitViewDelegate
@optional

///-----------------------------------
/// @name Customizing the split view behaviour
///-----------------------------------

/**
 */
- (NSInteger)numberOfViewsInSplitView:(CKSplitView*)view;

/**
 */
- (UIView*)splitView:(CKSplitView*)view viewAtIndex:(NSInteger)index;

/**
 */
- (CKSplitViewConstraints*)splitView:(CKSplitView*)view constraintsForViewAtIndex:(NSInteger)index;

@end


/**
 */
typedef enum CKSplitViewOrientation{
    CKSplitViewOrientationHorizontal,
    CKSplitViewOrientationVertical
}CKSplitViewOrientation;


/**
 */
@interface CKSplitView : UIView

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property(nonatomic,assign)id delegate;

///-----------------------------------
/// @name Customizing the split view
///-----------------------------------

/**
 */
@property(nonatomic,assign)CKSplitViewOrientation orientation;

///-----------------------------------
/// @name Reloading the split view
///-----------------------------------

/**
 */
- (void)reloadData;

@end

typedef enum CKSplitViewControllerAnimationState{
    CKSplitViewControllerAnimationStateRemoving,
    CKSplitViewControllerAnimationStateAdding,
    CKSplitViewControllerAnimationStateMoving
}CKSplitViewControllerAnimationState;

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
/// @name Getting the Split View
///-----------------------------------

/**
 */
@property (nonatomic, retain, readonly) CKSplitView* splitView;

/**
 */
@property(nonatomic,assign)CKSplitViewOrientation orientation;


///-----------------------------------
/// @name Managing the view controllers
///-----------------------------------

/**
 */
@property (nonatomic, copy) NSArray* viewControllers;

/**
 */
- (void)setViewControllers:(NSArray *)viewControllers 
         animationDuration:(NSTimeInterval)animationDuration
       startAnimationBlock:(void(^)(UIViewController* controller, CGRect beginFrame, CGRect endFrame, CKSplitViewControllerAnimationState state))startAnimationBlock
            animationBlock:(void(^)(UIViewController* controller, CGRect beginFrame, CGRect endFrame, CKSplitViewControllerAnimationState state))animationBlock
         endAnimationBlock:(void(^)(UIViewController* controller, CGRect beginFrame, CGRect endFrame, CKSplitViewControllerAnimationState state))endAnimationBlock;

@end



/**
 */
@interface UIViewController(CKSplitView)

///-----------------------------------
/// @name Customizing the split view constraints
///-----------------------------------

/**
 */
@property(nonatomic,retain)CKSplitViewConstraints* splitViewConstraints;
@end