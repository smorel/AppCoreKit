//
//  CKViewController+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#ifdef DEBUG

#import "CKViewController+InlineDebugger.h"
#import "CKNSObject+InlineDebugger.h"

@implementation UIViewController (CKInlineDebugger)

+ (CKTableViewCellController*)cellControllerForViewController:(UIViewController*)c withDebugger:(UIViewController*)debugger{
    NSString* title = nil;
    NSString* subtitle = nil;
    if([c respondsToSelector:@selector(name)]){
        NSString* name = [c performSelector:@selector(name)];
        if(name != nil && [name isKindOfClass:[NSString class]] && [name length] > 0){
            title = name;
        }
    }
    
    if(title == nil){
        title = [[c class]description];
        subtitle = [NSString stringWithFormat:@"<%p>",c];
    }
    else{
        subtitle = [NSString stringWithFormat:@"%@ <%p>",[c class],c];
    }
    
    __block UIViewController* bController = c;
    __block UIViewController* bDebugger = debugger;
    
    CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:title subtitle:subtitle action:^(CKTableViewCellController* controller){
        CKFormTableViewController* controllerForm = [[bController class]inlineDebuggerForObject:bController];
        controllerForm.title = title;
        [bDebugger.navigationController pushViewController:controllerForm animated:YES];
    }];
    
    return cellController;
}

- (CKFormTableViewController*)inlineDebuggerForSubView:(UIView*)view{
    CKFormTableViewController* debugger = [[view class]inlineDebuggerForObject:view];
    
    NSMutableArray* cellControllers = [NSMutableArray array];
    UIViewController* c = self;
    while(c){
        [cellControllers insertObject:[CKViewController cellControllerForViewController:c withDebugger:debugger] atIndex:0];
        if([c respondsToSelector:@selector(containerViewController)]){
            c = [c performSelector:@selector(containerViewController)];
        }
        else{
            c = nil;
        }
    }
    
    [cellControllers insertObject:[CKViewController cellControllerForViewController:self.navigationController withDebugger:debugger] atIndex:0];
    
    CKFormSection* section = [CKFormSection sectionWithCellControllers:cellControllers headerTitle:@"Controller Hierarchy"];
    
    int i =0;
    for(CKFormSectionBase* section in debugger.sections){
        if([section.headerTitle isEqualToString:@"Class Hierarchy"]){
            break;
        }
        ++i;
    }
    
    [debugger insertSection:section atIndex:i];
    
    return debugger;
}

@end

#endif
