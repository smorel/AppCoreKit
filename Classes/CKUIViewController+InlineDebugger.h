//
//  CKUIViewController+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKUIViewController.h"
#import "CKNSObject+InlineDebugger.h"

@class CKFormTableViewController;
@interface CKUIViewController (CKInlineDebugger)

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view;

@end
