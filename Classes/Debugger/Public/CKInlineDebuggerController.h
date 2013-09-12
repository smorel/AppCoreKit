//
//  CKInlineDebuggerController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CKInlineDebuggerControllerHighlightViewTag   -5647839

typedef NS_ENUM(NSInteger, CKInlineDebuggerControllerState){
    CKInlineDebuggerControllerStatePending,
    CKInlineDebuggerControllerStateDebugging
};

/**
 */
@interface CKInlineDebuggerController : NSObject

///-----------------------------------
/// @name Creating a Debugger Controller
///-----------------------------------

/**
 */
- (id)initWithViewController:(UIViewController*)viewController;

///-----------------------------------
/// @name Managing Debugger Controller State
///-----------------------------------

/**
 */
@property(nonatomic,readonly)CKInlineDebuggerControllerState state;

/** This enables gestures in navigation bar allowing debugger to be activated.
 */
- (void)start;

/** This disable gestures in navigation bar
 */
- (void)stop;

/** This replaces navigation bar items and highlights views. Views can be selected by tapping or moving fingers through the specified view.
 */
- (void)setActive:(BOOL)bo  withView:(UIView*)view;

@end