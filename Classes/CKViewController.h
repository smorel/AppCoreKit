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
#import "CKStyleManager.h"

@class CKViewController;
@class CKFormTableViewController;

typedef void(^CKViewControllerAnimatedBlock)(CKViewController* controller,BOOL animated);
typedef void(^CKViewControllerBlock)(CKViewController* controller);
typedef void(^CKViewControllerOrientationBlock)(CKViewController* controller, UIInterfaceOrientation orientation);

typedef void(^CKViewControllerEditingBlock)(BOOL editing);

/** 
 */
typedef enum CKInterfaceOrientation{
#ifdef __IPHONE_6_0
    CKInterfaceOrientationPortrait  = UIInterfaceOrientationMaskPortrait,
    CKInterfaceOrientationLandscape = UIInterfaceOrientationMaskLandscape,
#else
    CKInterfaceOrientationPortrait  = 1 << 0,
    CKInterfaceOrientationLandscape = 1 << 1,
#endif
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
/// @name Creating initialized View Controller Objects
///-----------------------------------

/** 
 This returns an autorelease view controller of the calling class.
 */
+ (id)controller;

/** 
 This returns an autorelease view controller of the calling class by initializing its name property with the specified name.
 */
+ (id)controllerWithName:(NSString*)name;

/**
 This returns an autorelease view controller of the calling class initializing it style manager using the specified stylesheetFileName.
 */
+ (id)controllerWithStylesheetFileName:(NSString*)stylesheetFileName;

/**
 This returns an autorelease view controller of the calling class by initializing its name property with the specified name and its style manager using the specified stylesheetFileName.
 */
+ (id)controllerWithName:(NSString*)name stylesheetFileName:(NSString*)stylesheetFileName;

///-----------------------------------
/// @name Identifying View Controller at runtime
///-----------------------------------
/** 
 Setting a name is almost only used for stylesheets.
 You can then target this view controller easily for customization using "CKViewController[name=YourControllerName] : { ... }".
 */
@property (nonatomic,retain) NSString* name;

///-----------------------------------
/// @name Customizing View Controller behaviour
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
/// @name Managing Interface Orientation
///-----------------------------------

/** 
 This bitmask defines the interface orientations supported by this view controller.
 The possible values are:
 * CKInterfaceOrientationPortrait
 * UIInterfaceOrientationMaskPortrait (IOS6 and later)
 * CKInterfaceOrientationLandscape
 * UIInterfaceOrientationMaskLandscape (IOS6 and later)
*/
@property (nonatomic,assign) CKInterfaceOrientation supportedInterfaceOrientations;

///-----------------------------------
/// @name Managing the Inline Debugger
///-----------------------------------

/** 
 This is an access to the inline debugger for this view controller.
 @warning This property is only available in DEBUG.
 */
@property(nonatomic,retain,readonly)CKInlineDebuggerController* inlineDebuggerController;

///-----------------------------------
/// @name Managing Navigation Bar Button Items
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
/// @name Getting the View Controller State
///-----------------------------------
/** 
 Specify the bar button item that should be displayed at the left of the navigation bar.
 */
@property (nonatomic, assign, readonly) CKViewControllerState state;

/** 
 Returns whether the view is currently displayed on screen or not
 */
@property (nonatomic, assign,readonly)  BOOL isViewDisplayed;

/**
 This block is called when the controller editing property changes changes
 */
@property (nonatomic, copy) CKViewControllerEditingBlock editingBlock;


///-----------------------------------
/// @name Managing Stylesheets
///-----------------------------------

/** 
 This method find the left style for the left bar button and apply this style on it.
 */
- (void)applyStyleForLeftBarButtonItem;

/** 
 This method find the right style for the left bar button and apply this style on it.
 */
- (void)applyStyleForRightBarButtonItem;

/** 
 This method applies style on the view controller and its subview,the navigation controller, its navigationbar and toolbar and bar buttons.
 */
- (void)applyStyleForNavigation;

/**
 This method applies style on the view controller and its subviews..
 */
- (void)applyStyleForController;

/** 
 */
- (NSMutableDictionary*)stylesheet;

///-----------------------------------
/// @name Private
///-----------------------------------

/** 
 This method is called upon initialization. Subclasses can override this method.
 @warning You should not call this method directly.
 */
- (void)postInit;

- (void)reapplyStylesheet;

@end


