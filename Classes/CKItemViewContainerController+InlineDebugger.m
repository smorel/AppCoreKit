//
//  CKItemViewContainerController+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKItemViewContainerController+InlineDebugger.h"

@implementation CKItemViewContainerController (CKInlineDebugger)

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view{
    CKFormTableViewController* debugger = [super inlineDebuggerForSubView:view];
    
    UIView* v = view;
    while(v){
        id itemController = [_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:v]];
        if(itemController){
            CKFormSection* controllerSection = (CKFormSection*)[debugger sectionAtIndex:0];
            
            NSString* title = [NSString stringWithFormat:@"%@ <%p>",[itemController class],itemController];
            NSString* subtitle = nil;
            if([itemController respondsToSelector:@selector(name)]){
                subtitle = title;
                title = [itemController performSelector:@selector(name)];
            }
            __block id bItemController = itemController;
            __block CKFormTableViewController* bDebugger = debugger;
            CKFormCellDescriptor* itemControllerCell = [CKFormCellDescriptor cellDescriptorWithTitle:title subtitle:subtitle action:^{
                CKFormTableViewController* controllerForm = [[[CKFormTableViewController alloc]init]autorelease];
                controllerForm.title = title;
                CKFormSection* controllerSection = [CKFormSection sectionWithObject:bItemController headerTitle:nil];
                [controllerForm addSections:[NSArray arrayWithObject:controllerSection]];
                [bDebugger.navigationController pushViewController:controllerForm animated:YES];
            }];
            
            [controllerSection addCellDescriptor:itemControllerCell];
            return debugger;
        }
        v = [v superview];
    }
    
    return debugger;
}

@end
