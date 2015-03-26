//
//  UIViewController+InlineDebugger.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//


#import "UIViewController+InlineDebugger.h"
#import "NSObject+InlineDebugger.h"
#import "CKContainerViewController.h"
#import "CKStandardContentViewController.h"

@implementation UIViewController (CKInlineDebugger)

+ (CKStandardContentViewController*)controllerForViewController:(UIViewController*)c withDebugger:(UIViewController*)debugger{
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
    
    CKStandardContentViewController* controller = [CKStandardContentViewController controllerWithTitle:title subtitle:subtitle action:^(CKStandardContentViewController* controller){
        CKTableViewController* controllerForm = [[bController class]inlineDebuggerForObject:bController];
        controllerForm.title = title;
        [bDebugger.navigationController pushViewController:controllerForm animated:YES];
    }];
    
    return controller;
}

- (CKTableViewController*)inlineDebuggerForSubView:(UIView*)view{
    CKTableViewController* debugger = [[view class]inlineDebuggerForObject:view];
    
    //TODO : Fixme use view to find controller and cell controller hierarchy !
    
    NSMutableArray* controllers = [NSMutableArray array];
    UIViewController* c = self;
    while(c){
        [controllers insertObject:[CKViewController controllerForViewController:c withDebugger:debugger] atIndex:0];
        if([c respondsToSelector:@selector(containerViewController)]){
            c = [c performSelector:@selector(containerViewController)];
        }
        else{
            c = nil;
        }
    }
    
    [controllers insertObject:[CKViewController controllerForViewController:self.navigationController withDebugger:debugger] atIndex:0];
    
    CKSection* section = [CKSection sectionWithControllers:controllers];
    [section setHeaderTitle:@"Controller Hierarchy"];
    
    int i =0;
    for(CKAbstractSection* section in debugger.sectionContainer.sections){
        if([section.name isEqualToString:@"ClassHierarchy"]){
            break;
        }
        ++i;
    }
    
    [debugger insertSection:section atIndex:i animated:NO];
    
    return debugger;
}

@end
