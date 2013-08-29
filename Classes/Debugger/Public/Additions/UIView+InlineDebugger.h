//
//  UIView+InlineDebugger.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NSObject+InlineDebugger.h"

/**
 */
@interface UIView (CKInlineDebugger)

///-----------------------------------
/// @name Creating a Debugger for view hierarchy
///-----------------------------------

/**
 */
+ (CKFormTableViewController*)inlineDebuggerForSubViewsOfView:(UIView*)view;

@end
