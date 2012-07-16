//
//  CKUIViewController+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKUIViewController.h"
#import "CKNSObject+InlineDebugger.h"

@class CKFormTableViewController;
@interface UIViewController (CKInlineDebugger)

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view;

@end
