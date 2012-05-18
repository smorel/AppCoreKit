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
            int i =0;
            for(CKFormSectionBase* section in debugger.sections){
                if([section.headerTitle isEqualToString:@"Controller Hierarchy"]){
                    break;
                }
                ++i;
            }
            
            CKFormSection* controllerSection = (CKFormSection*)[debugger sectionAtIndex:i];
            
            NSString* title = nil;
            NSString* subtitle = nil;
            if([itemController respondsToSelector:@selector(name)]){
                NSString* name = [itemController performSelector:@selector(name)];
                if(name != nil && [name isKindOfClass:[NSString class]] && [name length] > 0
                   && ![name hasPrefix:@"cellDescriptorWithTitle<"]){
                    title = name;
                }
            }
            
            if(title == nil){
                title = [[itemController class]description];
                subtitle = [NSString stringWithFormat:@"<%p>",itemController];
            }
            else{
                subtitle = [NSString stringWithFormat:@"%@ <%p>",[itemController class],itemController];
            }

            __block id bItemController = itemController;
            __block CKFormTableViewController* bDebugger = debugger;
            
            CKTableViewCellController* itemControllerCell = [CKTableViewCellController cellControllerWithTitle:title subtitle:subtitle action:^(CKTableViewCellController* controller){
                CKFormTableViewController* controllerForm = [[bItemController class]inlineDebuggerForObject:bItemController];
                controllerForm.title = title;
                [bDebugger.navigationController pushViewController:controllerForm animated:YES];
            }];
            
            [controllerSection addCellController:itemControllerCell];
            
            return debugger;
        }
        v = [v superview];
    }
    
    return debugger;
}

@end
