//
//  CKNSObject+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKFormTableViewController.h"

@interface NSObject (CKInlineDebugger)

+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object;

@end
