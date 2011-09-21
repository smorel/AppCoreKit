//
//  CKTableViewCellController+StyleManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewController+StyleManager.h"
#import "CKTableViewCellController+Style.h"
#import "CKNSObject+Bindings.h"

@interface CKItemViewController()
@property (nonatomic, retain, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) UIViewController* parentController;
@end

static NSMutableDictionary* CKTableViewCellControllerInstances = nil;

@implementation CKItemViewController (CKStyleManager)

+ (void)flush:(NSNotification*)notif{
	[CKTableViewCellControllerInstances removeAllObjects];
}


+ (NSString*)identifierForItem:(CKObjectViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
	CKItemViewController* controller = [CKItemViewController controllerForItem:item object:object indexPath:indexPath parentController:parentController];
	return [controller identifier];
}


+ (NSMutableDictionary*)styleForItem:(CKObjectViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
	CKItemViewController* controller = [CKItemViewController controllerForItem:item object:object indexPath:indexPath parentController:parentController];
	return [controller controllerStyle];
}


+ (CKItemViewController*)controllerForItem:(CKObjectViewControllerFactoryItem*)item object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
    CKItemViewController* controller = [CKItemViewController controllerForClass:item.controllerClass object:object indexPath:indexPath parentController:parentController];
	CKCallback* callback = [item createCallback];
    controller.createCallback = callback;
	if(callback){
		[callback execute:controller];
	}
    if(controller.view == nil){
        controller.view = [controller loadView];
        //As controller.view is a weak ref and this view will not get retained by the table, we keep a reference on it as a retain.
		[CKTableViewCellControllerInstances setObject:controller.view forKey:[NSString stringWithFormat:@"<%p>",controller.view]];
    }
    return controller;
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
	[controller setIndexPath:indexPath];
	[controller setValue:object];	
    
	return controller;
}

@end
