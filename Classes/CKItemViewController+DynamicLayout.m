//
//  CKItemViewController+DynamicLayout.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController+DynamicLayout.h"
#import "CKTableViewCellController+Style.h"
#import "CKNSObject+Bindings.h"

#import "CKStyleManager.h"
#import "CKTableViewCellController+Style.h"
#import "CKObjectTableViewController.h"

#import "CKFormCellDescriptor.h"


@interface CKItemViewControllerFactoryItem() 
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
@end

@interface CKItemViewController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) UIViewController* parentController;
@end

static NSMutableDictionary* CKTableViewCellControllerInstances = nil;

@implementation CKItemViewController (CKDynamicLayout)

+ (void)flush:(NSNotification*)notif{
	[CKTableViewCellControllerInstances removeAllObjects];
}

+ (CKItemViewController*)controllerForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
	if(CKTableViewCellControllerInstances == nil){
		CKTableViewCellControllerInstances = [[NSMutableDictionary dictionary]retain];
		
		[CKTableViewCellControllerInstances beginBindingsContextByRemovingPreviousBindings];
		[[NSNotificationCenter defaultCenter]bindNotificationName:UIApplicationDidReceiveMemoryWarningNotification target:[CKItemViewController class] action:@selector(flush:)];
		[CKTableViewCellControllerInstances endBindingsContext];
	}
	
    BOOL created = NO;
	CKItemViewController* controller = [CKTableViewCellControllerInstances objectForKey:theClass];
	if(controller == nil){
		controller = [[[theClass alloc]init]autorelease];
        created = YES;
		[CKTableViewCellControllerInstances setObject:controller forKey:theClass];
	}
	
	controller.name = nil;
	[controller setParentController:parentController];
	[controller setValue:object];	
	[controller setIndexPath:indexPath];
    
	return controller;
}


+ (CKItemViewController*)controllerForItem:(CKItemViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
    CKItemViewController* controller = nil;
    if(item.controllerCreateBlock){
        controller = [item controllerForObject:object atIndexPath:indexPath];
    }
    else{
        controller = [CKItemViewController controllerForClass:item.controllerClass object:object indexPath:indexPath parentController:parentController];
        CKCallback* callback = [item createCallback];
        controller.createCallback = callback;
    }
       
    if(controller.createCallback){
        [controller.createCallback execute:controller];
    }
    
    if(controller.view == nil){
        controller.view = [controller loadView];
            //As controller.view is a weak ref and this view will not get retained by the table, we keep a reference on it as a retain.
		[CKTableViewCellControllerInstances setObject:controller.view forKey:[NSString stringWithFormat:@"<%p>",controller.view]];
    }
    return controller;
}

+ (CKItemViewController*)setupStaticControllerForItem:(CKItemViewControllerFactoryItem*)item
                                             inParams:(NSMutableDictionary*)params 
                                            withStyle:(NSMutableDictionary*)controllerStyle 
                                           withObject:(id)object 
                                        withIndexPath:(NSIndexPath*)indexPath  
                                              forSize:(BOOL)forSize{
    if([item isKindOfClass:[CKFormCellDescriptor class]]){
        CKFormCellDescriptor* cellDescriptor = (CKFormCellDescriptor*)item;
        if(cellDescriptor.cellController){
            return cellDescriptor.cellController;
        }
    }
    
    
    CKItemViewController* staticController = (CKItemViewController*)[CKItemViewController controllerForItem:item
                                                                                                     object:object 
                                                                                                  indexPath:indexPath 
                                                                                           parentController:[params parentController]];
    
    if([staticController isKindOfClass:[CKTableViewCellController class]]){
        CKTableViewCellController* staticCellController = (CKTableViewCellController*)staticController;
            //Those conditions means values of interest are hardcoded in stylesheets
        if(forSize && [controllerStyle containsObjectForKey:CKStyleCellSize]){
            return nil;
        }
        if(!forSize && [controllerStyle containsObjectForKey:CKStyleCellFlags]){
            return nil;
        }
        
            //Retrieves the right style
        if([controllerStyle containsObjectForKey:CKStyleCellType]){
            staticCellController.cellStyle = [controllerStyle cellStyle];
        }
        if(staticCellController.cellStyle != CKTableViewCellStylePropertyGrid
           && staticCellController.cellStyle != CKTableViewCellStyleValue3
           && staticCellController.cellStyle != CKTableViewCellStyleSubtitle2){
            return nil;
        }
    }
    else{
        return nil;
    }
    
    staticController.initCallback = [item initCallback];
    staticController.setupCallback = [item setupCallback];
    staticController.selectionCallback = [item selectionCallback];
    staticController.accessorySelectionCallback = [item accessorySelectionCallback];
    staticController.becomeFirstResponderCallback = [item becomeFirstResponderCallback];
    staticController.resignFirstResponderCallback = [item resignFirstResponderCallback];
    staticController.viewDidAppearCallback = [item viewDidAppearCallback];
    staticController.viewDidDisappearCallback = [item viewDidDisappearCallback];
    staticController.layoutCallback = [item layoutCallback];
    [params setObject:staticController forKey:CKTableViewAttributeStaticController];
    if(controllerStyle){
        [params setObject:controllerStyle forKey:CKTableViewAttributeStaticControllerStyle];
    }
    if(staticController.view != nil){
        [staticController initView:staticController.view];
        [staticController setupView:staticController.view];	
    }
    
    if(forSize){
            //Resize for table views
        UIViewController* parentController = [params parentController];
        if([parentController isKindOfClass:[CKObjectTableViewController class]]){
            CKTableViewCellController* staticCellController = (CKTableViewCellController*)staticController;
            [staticCellController.tableViewCell setEditing:NO animated:NO];
            
            CGFloat tableWidth = [params bounds].width;
            if(staticController.view){
                UIView* accessoryView = staticCellController.tableViewCell.accessoryView;
                CGFloat accessorySize = accessoryView ? accessoryView.frame.size.width : 0;
                if(staticCellController.tableViewCell.accessoryType != UITableViewCellAccessoryNone){
                    accessorySize = 20;
                }
                CGFloat rowWidth = [CKTableViewCellController contentViewWidthInParentController:(CKObjectTableViewController*)[params parentController]] - accessorySize;
                staticCellController.tableViewCell.frame = CGRectMake(0,0,tableWidth-accessorySize,staticCellController.tableViewCell.frame.size.height);
                if(staticCellController.tableViewCell.contentView.frame.size.width != rowWidth){
                    CGFloat offset = rowWidth - staticCellController.tableViewCell.contentView.frame.size.width;
                    staticCellController.tableViewCell.frame = CGRectMake(0,0,tableWidth - accessorySize + offset,staticCellController.tableViewCell.frame.size.height);
                }
                [staticCellController.tableViewCell layoutSubviews];
            }
            
            UITableView* tableView = [(CKObjectTableViewController*)parentController tableView];
            BOOL tableEditing = [tableView isEditing];
            BOOL cellEditing = [staticCellController.tableViewCell isEditing];
                //FIXME : this is a private call.
            if(tableEditing != cellEditing){
                /*UITableViewCellEditingStyle
                 */
                /*if([staticCellController.tableViewCell respondsToSelector:@selector(setEditingStyle:)]){
                 CKItemViewFlags flags = [self flagsForObject:object atIndexPath:indexPath  withParams:params];
                 [staticCellController.tableViewCell setEditingStyle:flags & CKItemViewFlagRemovable ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone];
                 }*/
                [staticCellController.tableViewCell setEditing:tableEditing animated:NO];
                [staticCellController.tableViewCell layoutSubviews];
            }
        }
    }
    
    
    [staticController clearBindingsContext];
    [staticController.view clearBindingsContext];
    /*if([staticController respondsToSelector:@selector(cacheLayoutBindingContextId)]){
     [NSObject removeAllBindingsForContext:[staticController cacheLayoutBindingContextId]];
     }*/
    
    return staticController;
}

@end
