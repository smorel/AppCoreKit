//
//  CKViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKLocalization.h"
#import "CKInlineDebuggerController.h"

@class CKViewController;
@class CKFormTableViewController;

typedef void(^CKViewControllerAnimatedBlock)(CKViewController* controller,BOOL animated);
typedef void(^CKViewControllerBlock)(CKViewController* controller);
typedef void(^CKViewControllerOrientationBlock)(CKViewController* controller, UIInterfaceOrientation orientation);

/**
 */
typedef enum CKInterfaceOrientation{
    CKInterfaceOrientationPortrait  = 1 << 0,
    CKInterfaceOrientationLandscape = 1 << 1,
    CKInterfaceOrientationAll       = CKInterfaceOrientationPortrait | CKInterfaceOrientationLandscape
}CKInterfaceOrientation;

/**
 */
typedef enum CKViewControllerState{
    CKViewControllerStateNone           = 1 << 0,
    CKViewControllerStateWillAppear     = 1 << 1,
    CKViewControllerStateDidAppear      = 1 << 2,
    CKViewControllerStateWillDisappear  = 1 << 3,
    CKViewControllerStateDidDisappear   = 1 << 4,
    CKViewControllerStateDidUnload      = 1 << 5,
    CKViewControllerStateDidLoad        = 1 << 6
}CKViewControllerState;

/** 
 CKViewController is the base class providing helpers to build a view controller and manage customization with stylesheet.
 It also provides convenient blocks to define a view controller inline instead of subclassing it.
 You can define some elements for navigation like left/right bar buttons and the supported interface orientations without having to subclass it.
 */
@interface CKViewController : UIViewController {
	NSString* _name;
}

///-----------------------------------
/// @name Creating Controller Objects
///-----------------------------------
/** 
 This returns an autorelease view controller of the calling class.
 */
+ (id)controller;
/** 
 This returns an autorelease view controller of the calling class by initializing its name property with the specified name.
 */
+ (id)controllerWithName:(NSString*)name;

///-----------------------------------
/// @name Identification
///-----------------------------------
/** 
 Setting a name is almost only used for stylesheets.
 You can then target this view controller easily for customization using "CKViewController[name=YourControllerName] : { ... }".
 */
@property (nonatomic,retain) NSString* name;

///-----------------------------------
/// @name View Controller Definition
///-----------------------------------
/** 
 This block is called at the begining of viewWillAppear
 Use this block to setup bindings between your document data and the views.
 */
@property (nonatomic,copy) CKViewControllerAnimatedBlock viewWillAppearBlock;

/** 
 This block is called at the end of viewWillAppear when styles have been applied.
 Use this block if some of your code is dependent of data set by style.
 For exemple, if you need to layout some views and you defined size or frames for some elements in the stylesheets.
 */
@property (nonatomic,copy) CKViewControllerAnimatedBlock viewWillAppearEndBlock;

/** 
 This block is called at the begining of viewDidAppear
 */
@property (nonatomic,copy) CKViewControllerAnimatedBlock viewDidAppearBlock;

/** 
 This block is called at the end of viewWillDisappear
 */
@property (nonatomic,copy) CKViewControllerAnimatedBlock viewWillDisappearBlock;

/** 
 This block is called at the end of viewDidDisappear
 */
@property (nonatomic,copy) CKViewControllerAnimatedBlock viewDidDisappearBlock;

/** 
 This block is called at the end of viewDidLoad.
 Use this block to setup your view by adding subviews.
 */
@property (nonatomic,copy) CKViewControllerBlock viewDidLoadBlock;

/** 
 This block is called at the end of viewWillDisappear
 */
@property (nonatomic,copy) CKViewControllerBlock viewDidUnloadBlock;

/** 
 This block is called when the controller is deallocated
 */
@property (nonatomic,copy) CKViewControllerBlock deallocBlock;

/** 
 This block is called when the controller orientation changes
 */
@property (nonatomic, copy) CKViewControllerOrientationBlock orientationChangeBlock;

///-----------------------------------
/// @name Interface Orientation
///-----------------------------------

/** 
 This property will define the interface orientations supported by this view controller.
 */
@property (nonatomic,assign) CKInterfaceOrientation supportedInterfaceOrientations;

///-----------------------------------
/// @name Inline Debugger
///-----------------------------------

/** 
 This is an access to the inline debugger for this view controller.
 */
#ifdef DEBUG
@property(nonatomic,retain,readonly)CKInlineDebuggerController* inlineDebuggerController;
#endif

///-----------------------------------
/// @name Navigation
///-----------------------------------
/** 
 Specify the bar button item that should be displayed at the right of the navigation bar.
 */
@property (nonatomic, retain) UIBarButtonItem *rightButton;

/** 
 Specify the bar button item that should be displayed at the left of the navigation bar.
 */
@property (nonatomic, retain) UIBarButtonItem *leftButton;


///-----------------------------------
/// @name State
///-----------------------------------
/** 
 Specify the bar button item that should be displayed at the left of the navigation bar.
 */
@property (nonatomic, assign, readonly) CKViewControllerState state;

/** 
 Returns whether the view is currently displayed on screen or not
 */
@property (nonatomic, assign,readonly)  BOOL isViewDisplayed;

///-----------------------------------
/// @name Private
///-----------------------------------

/** 
 This method is called upon initialization. Subclasses can override this method.
 @warning You should not call this method directly.
 */
- (void)postInit;

- (void)applyStyleForLeftBarButtonItem;
- (void)applyStyleForRightBarButtonItem;
- (void)applyStyleForNavigation;


- (void)updateStylesheets;

@end


