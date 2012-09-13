//
//  NSObject+InlineDebugger.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKFormTableViewController.h"

/**
 */
@interface NSObject (CKInlineDebugger)

///-----------------------------------
/// @name Creating a Debugger
///-----------------------------------

/**
 */
+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object;

@end
