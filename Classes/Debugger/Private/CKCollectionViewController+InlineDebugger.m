//
//  CKCollectionViewControllerOld+InlineDebugger.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//


#import "CKCollectionViewController+InlineDebugger.h"

@interface CKCollectionViewControllerOld()

@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@property (nonatomic, retain) NSMutableDictionary* viewsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToViews;
@property (nonatomic, retain) NSMutableArray* weakViews;
@property (nonatomic, retain) NSMutableArray* sectionsToControllers;

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;

- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

@end

@implementation CKCollectionViewControllerOld (CKInlineDebugger)

- (id)itemControllerForSubView:(UIView*)view{
    UIView* v = view;
    while(v){
        id itemController = [self.viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:v]];
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
