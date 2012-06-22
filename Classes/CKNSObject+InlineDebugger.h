//
//  CKNSObject+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#ifdef DEBUG

#import <Foundation/Foundation.h>
#import "CKFormTableViewController.h"

/** TODO
 */
@interface NSObject (CKInlineDebugger)

///-----------------------------------
/// @name Creating a Debugger
///-----------------------------------

/**
 */
+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object;

@end

#endif
