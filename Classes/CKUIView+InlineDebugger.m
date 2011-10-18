//
//  CKUIView+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKUIView+InlineDebugger.h"

@implementation UIView (CKInlineDebugger)

+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object{
    CKFormTableViewController* debugger = [NSObject inlineDebuggerForObject:object];
    UIView* view = (UIView*)object;
    
    __block CKFormTableViewController* bController = debugger;
    if([view superview]){
        NSString* title = [NSString stringWithFormat:@"%@ <%p>",[[view superview] class],[view superview]];
        CKFormCellDescriptor* superViewCell = [CKFormCellDescriptor cellDescriptorWithTitle:title action:^{
            CKFormTableViewController* superViewForm = [[[view superview]class] inlineDebuggerForObject:[view superview]];
            superViewForm.title = title;
            [bController.navigationController pushViewController:superViewForm animated:YES];
        }];
        
        CKFormSection* superViewSection = [CKFormSection sectionWithCellDescriptors:[NSArray arrayWithObject:superViewCell] headerTitle:@"Super View"];
        [debugger insertSection:superViewSection atIndex:0];
    }
    
    return debugger;
}

@end
