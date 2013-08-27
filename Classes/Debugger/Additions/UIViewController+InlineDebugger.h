//
//  UIViewController+InlineDebugger.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKViewController.h"
#import "NSObject+InlineDebugger.h"

@class CKFormTableViewController;
@interface UIViewController (CKInlineDebugger)

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view;

@end
