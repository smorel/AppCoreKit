//
//  UIViewController+InlineDebugger.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "NSObject+InlineDebugger.h"
#import "CKTableViewController.h"

@interface UIViewController (CKInlineDebugger)

- (CKTableViewController*)inlineDebuggerForSubView:(UIView*)view;

@end
