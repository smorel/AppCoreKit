//
//  CKUIView+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNSObject+InlineDebugger.h"

@interface UIView (CKInlineDebugger)

+ (CKFormTableViewController*)inlineDebuggerForSubViewsOfView:(UIView*)view;
+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object;

@end
