//
//  CKUIView+InlineDebugger.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNSObject+InlineDebugger.h"

@interface UIView (CKInlineDebugger)

+ (CKFormTableViewController*)inlineDebuggerForSubViewsOfView:(UIView*)view;

@end
