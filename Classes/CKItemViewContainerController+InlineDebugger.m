//
//  CKItemViewContainerController+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKItemViewContainerController+InlineDebugger.h"
#import "CKGridTableViewCellController.h"

@implementation CKItemViewContainerController (CKInlineDebugger)

- (id)itemControllerForSubView:(UIView*)view{
    UIView* v = view;
    while(v){
        id itemController = [_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:v]];
        if(itemController){
            return itemController;
        }
        v = [v superview];
    }
    return nil;
}

- (CKFormSection*)sectionForCellControllersInDebugger:(CKFormTableViewController*)debugger{
    int i =0;
    for(CKFormSectionBase* section in debugger.sections){
        if([section.headerTitle isEqualToString:@"Controller Hierarchy"]){
            break;
        }
        ++i;
    }
    
    CKFormSection* controllerSection = (CKFormSection*)[debugger sectionAtIndex:i];
    return controllerSection;
}

- (CKTableViewCellController*)cellControllerForItemViewController:(id)itemController debugger:(CKFormTableViewController*)debugger{
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
    return itemControllerCell;
}

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view{
    CKFormTableViewController* debugger = [super inlineDebuggerForSubView:view];
    id itemController = [self itemControllerForSubView:view];
    
    if(itemController){
        CKFormSection* controllerSection = [self sectionForCellControllersInDebugger:debugger];
        [controllerSection addCellController:[self cellControllerForItemViewController:itemController debugger:debugger]];
    }
    
    return debugger;
}

@end

@implementation CKBindedGridViewController (CKInlineDebugger)

- (id)subItemControllerForSubView:(UIView*)view inControllers:(NSArray*)itemViewControllers{
    UIView* v = view;
    while(v){
        for(CKItemViewController* controller in itemViewControllers){
            UIView* controllerView = [controller view];
            if(controllerView == v){
                return controller;
            }
        }
        v = [v superview];
    }
    return nil;
}

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view{
    CKFormTableViewController* debugger = [super inlineDebuggerForSubView:view];
    CKGridTableViewCellController* itemController = (CKGridTableViewCellController*)[self itemControllerForSubView:view];
    
    if(itemController){
        CKFormSection* controllerSection = [self sectionForCellControllersInDebugger:debugger];
        
        id subItemController = [self subItemControllerForSubView:view inControllers:itemController.cellControllers];
        if(subItemController){
            [controllerSection addCellController:[self cellControllerForItemViewController:subItemController debugger:debugger]];
        }
    }
    
    return debugger;
}

@end