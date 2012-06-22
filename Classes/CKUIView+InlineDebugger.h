//
//  CKUIView+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#ifdef DEBUG

#import <UIKit/UIKit.h>
#import "CKNSObject+InlineDebugger.h"

/** TODO
 */
@interface UIView (CKInlineDebugger)

///-----------------------------------
/// @name Creating a Debugger for view hierarchy
///-----------------------------------

/**
 */
+ (CKFormTableViewController*)inlineDebuggerForSubViewsOfView:(UIView*)view;

@end

#endif
