//
//  CKUIViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKLocalization.h"
#import "CKInlineDebuggerController.h"

@class CKUIViewController;
@class CKFormTableViewController;

typedef void(^CKUIViewControllerAnimatedBlock)(CKUIViewController* controller,BOOL animated);
typedef void(^CKUIViewControllerBlock)(CKUIViewController* controller);
typedef void(^CKUIViewControllerOrientationBlock)(CKUIViewController* controller, UIInterfaceOrientation orientation);

typedef enum CKInterfaceOrientation{
    CKInterfaceOrientationPortrait  = 1 << 0,
    CKInterfaceOrientationLandscape = 1 << 1,
    CKInterfaceOrientationAll       = CKInterfaceOrientationPortrait | CKInterfaceOrientationLandscape
}CKInterfaceOrientation;

typedef enum CKUIViewControllerState{
    CKUIViewControllerStateNone           = 1 << 0,
    CKUIViewControllerStateWillAppear     = 1 << 1,
    CKUIViewControllerStateDidAppear      = 1 << 2,
    CKUIViewControllerStateWillDisappear  = 1 << 3,
    CKUIViewControllerStateDidDisappear   = 1 << 4,
    CKUIViewControllerStateDidUnload      = 1 << 5,
    CKUIViewControllerStateDidLoad        = 1 << 6
}CKUIViewControllerState;

/** 
 CKUIViewController is the base class providing helpers to build a view controller and manage customization with stylesheet.
 It also provides convenient blocks to define a view controller inline instead of subclassing it.
 You can define some elements for navigation like left/right bar buttons and the supported interface orientations without having to subclass it.
 */
@interface CKUIViewController : UIViewController {
	NSString* _name;
}

///-----------------------------------
/// @name Constructor
///-----------------------------------
/** 
 This returns an autorelease view controller of the calling class.
 */
+ (id)controller;

///-----------------------------------
/// @name Identification
///-----------------------------------
/** 
 Setting a name is almost only used for stylesheets.
 You can then target this view controller easily for customization using "CKUIViewController[name=YourControllerName] : { ... }".
 */
@property (nonatomic,retain) NSString* name;

///-----------------------------------
/// @name View Controller Definition
///-----------------------------------
/** 
 This block is called at the begining of viewWillAppear
 Use this block to setup bindings between your document data and the views.
 */
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewWillAppearBlock;

/** 
 This block is called at the end of viewWillAppear when styles have been applied.
 Use this block if some of your code is dependent of data set by style.
 For exemple, if you need to layout some views and you defined size or frames for some elements in the stylesheets.
 */
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewWillAppearEndBlock;

/** 
 This block is called at the begining of viewDidAppear
 */
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewDidAppearBlock;

/** 
 This block is called at the end of viewWillDisappear
 */
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewWillDisappearBlock;

/** 
 This block is called at the end of viewDidDisappear
 */
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewDidDisappearBlock;

/** 
 This block is called at the end of viewDidLoad.
 Use this block to setup your view by adding subviews.
 */
@property (nonatomic,copy) CKUIViewControllerBlock viewDidLoadBlock;

/** 
 This block is called at the end of viewWillDisappear
 */
@property (nonatomic,copy) CKUIViewControllerBlock viewDidUnloadBlock;

/** 
 This block is called when the controller is deallocated
 */
@property (nonatomic,copy) CKUIViewControllerBlock deallocBlock;

/** 
 This block is called when the controller orientation changes
 */
@property (nonatomic, copy) CKUIViewControllerOrientationBlock orientationChangeBlock;

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
@property(nonatomic,retain,readonly)CKInlineDebuggerController* inlineDebuggerController;

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
@property (nonatomic, assign, readonly) CKUIViewControllerState state;

/** 
 Returns whether the view is currently displayed on screen or not
 */
@property (nonatomic, assign,readonly)  BOOL viewIsOnScreen;

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

@end


