//
//  CKUIView+InlineDebugger.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-17.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKUIView+InlineDebugger.h"

@implementation UIView (CKInlineDebugger)


+ (CKFormCellDescriptor*)cellDescriptorForStylesheetInView:(UIView*)view withDebugger:(UIViewController*)debugger{
    /*
    
    //************************* TODO
    
    Creates a cell for the style with name = the PATH + action displaying the content of the style !
        Header section should be @"Applied Style"
        
        //*******************************************************
        
        NSMutableDictionary* style = [view appliedStyle];
    
    NSString* title = [NSString stringWithFormat:@"%@ <%p>",[c class],c];
    NSString* subtitle = nil;
    if([c respondsToSelector:@selector(name)]){
        subtitle = title;
        title = [c performSelector:@selector(name)];
    }
    
    __block UIViewController* bController = c;
    __block UIViewController* bDebugger = debugger;
    CKFormCellDescriptor* controllerCell = [CKFormCellDescriptor cellDescriptorWithTitle:title subtitle:subtitle action:^{
        CKFormTableViewController* controllerForm = [[[CKFormTableViewController alloc]init]autorelease];
        controllerForm.searchEnabled = YES;
        
        controllerForm.title = title;
        CKFormSection* controllerSection = [CKFormSection sectionWithObject:bController headerTitle:nil];
        [controllerForm addSections:[NSArray arrayWithObject:controllerSection]];
        
        __block CKFormTableViewController* bControllerForm = controllerForm;
        __block UIViewController* bbController = bController;
        controllerForm.searchBlock = ^(NSString* filter){
            [bControllerForm clear];
            
            CKFormSection* newControllerSection = [CKFormSection sectionWithObject:bbController propertyFilter:filter headerTitle:nil];
            [bControllerForm addSections:[NSArray arrayWithObject:newControllerSection]];
        };
        
        [bDebugger.navigationController pushViewController:controllerForm animated:YES];
    }];
    return controllerCell;
     */
    
    return nil;
}

+ (CKFormTableViewController*)inlineDebuggerForObject:(id)object{
    CKFormTableViewController* debugger = [NSObject inlineDebuggerForObject:object];
    UIView* view = (UIView*)object;
    
    //adds style section
    
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
