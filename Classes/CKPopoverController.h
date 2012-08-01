//
//  CKPopoverController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKPopoverController;

@interface CKPopoverManager : NSObject
@property(nonatomic,retain) NSSet* nonRetainedPopoverControllerValues;
@end


typedef void(^CKPopoverControllerDismissBlock)(CKPopoverController* popover);

/** 
 CKPopoverController is an autonomous version of UIPopoverController that will retain itself when presented and autorelease itself when dismissed. This avoid client code to retain the popover while it is displayed. It is also registered on interface orientation change and can optionally dismiss itsel automatically.
 CKPopoverController also provides some helpers to add the contentViewController in navigation controller at init.
 */
@interface CKPopoverController : UIPopoverController<UIPopoverControllerDelegate> {}

///-----------------------------------
/// @name Initializing a CKPopoverController
///-----------------------------------

/**
 */
- (id)initWithContentViewController:(UIViewController *)viewController;

/**
 */
- (id)initWithContentViewController:(UIViewController *)viewController contentSize:(CGSize)contentSize;

/**
 */
- (id)initWithContentViewController:(UIViewController *)viewController inNavigationController:(BOOL)navigationController;

/**
 */
- (id)initWithContentViewController:(UIViewController *)viewController contentSize:(CGSize)contentSize inNavigationController:(BOOL)navigationController;

/**
 */
- (void)postInit;

///-----------------------------------
/// @name Configuring a CKPopoverController
///-----------------------------------

/** default value is YES
 */
@property (nonatomic,assign)BOOL autoDismissOnInterfaceOrientation;

///-----------------------------------
/// @name Reacting to CKPopoverController events
///-----------------------------------

/**
 */
@property (nonatomic,copy) CKPopoverControllerDismissBlock didDismissPopoverBlock;


@end

/**
 */
@interface UIViewController (CKPopoverController)

///-----------------------------------
/// @name Popover
///-----------------------------------

/**
 */
@property(nonatomic,assign,readonly) BOOL isInPopover;

@end