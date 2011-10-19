//
//  CKUIViewController+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKUIViewController+InlineDebugger.h"
#import "CKNSObject+InlineDebugger.h"

@implementation UIViewController (CKInlineDebugger)

+ (CKFormCellDescriptor*)cellDescriptorForController:(UIViewController*)c withDebugger:(UIViewController*)debugger{
    NSString* title = [NSString stringWithFormat:@"%@ <%p>",[c class],c];
    NSString* subtitle = nil;
    if([c respondsToSelector:@selector(name)]){
        subtitle = title;
        title = [c performSelector:@selector(name)];
    }
    
    __block UIViewController* bController = c;
    __block UIViewController* bDebugger = debugger;
    CKFormCellDescriptor* controllerCell = [CKFormCellDescriptor cellDescriptorWithTitle:title subtitle:subtitle action:^{
        CKFormTableViewController* controllerForm = [[bController class]inlineDebuggerForObject:bController];
        [bDebugger.navigationController pushViewController:controllerForm animated:YES];
    }];
    
    [controllerCell setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.cellStyle = CKTableViewCellStyleSubtitle;
        return (id)nil;
    }];
    return controllerCell;
}

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view{
    CKFormTableViewController* debugger = [[view class]inlineDebuggerForObject:view];
    
    NSMutableArray* controllerCells = [NSMutableArray array];
    UIViewController* c = self;
    while(c){
        [controllerCells insertObject:[CKUIViewController cellDescriptorForController:c withDebugger:debugger] atIndex:0];
        if([c respondsToSelector:@selector(containerViewController)]){
            c = [c performSelector:@selector(containerViewController)];
        }
        else{
            c = nil;
        }
    }
    
    [controllerCells insertObject:[CKUIViewController cellDescriptorForController:self.navigationController withDebugger:debugger] atIndex:0];
    
    CKFormSection* controllerSection = [debugger insertSectionWithCellDescriptors:controllerCells atIndex:0];
    controllerSection.headerTitle = @"Controllers";
    
    return debugger;
}

@end
