//
//  CKViewController+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#ifdef DEBUG

#import "CKViewController.h"
#import "CKNSObject+InlineDebugger.h"

@class CKFormTableViewController;
@interface UIViewController (CKInlineDebugger)

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view;

@end

#endif
