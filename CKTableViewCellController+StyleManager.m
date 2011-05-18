//
//  CKTableViewCellController+StyleManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController+StyleManager.h"
#import "CKTableViewCellController+Style.h"
#import "CKNSObject+Bindings.h"

static NSMutableDictionary* CKTableViewCellControllerInstances = nil;

@implementation CKTableViewCellController (CKStyleManager)

+ (void)flush:(NSNotification*)notif{
	[CKTableViewCellControllerInstances removeAllObjects];
}

+ (NSString*)identifierForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
	CKTableViewCellController* controller = [CKTableViewCellController controllerForClass:theClass object:object indexPath:indexPath parentController:parentController];
	return [controller identifier];
}

+ (NSMutableDictionary*)styleForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
	CKTableViewCellController* controller = [CKTableViewCellController controllerForClass:theClass object:object indexPath:indexPath parentController:parentController];
	return [controller controllerStyle];
}

+ (CKTableViewCellController*)controllerForClass:(Class)theClass object:(id)object indexPath:(NSIndexPath*)indexPath parentController:(id)parentController{
	if(CKTableViewCellControllerInstances == nil){
		CKTableViewCellControllerInstances = [[NSMutableDictionary dictionary]retain];
		
		[CKTableViewCellControllerInstances beginBindingsContextByRemovingPreviousBindings];
		[[NSNotificationCenter defaultCenter]bindNotificationName:UIApplicationDidReceiveMemoryWarningNotification target:[CKTableViewCellController class] action:@selector(flush:)];
		[CKTableViewCellControllerInstances endBindingsContext];
	}
	
	CKTableViewCellController* controller = [CKTableViewCellControllerInstances objectForKey:theClass];
	if(controller == nil){
		controller = [[[theClass alloc]init]autorelease];
		[CKTableViewCellControllerInstances setObject:controller forKey:theClass];
	}
	
	[controller performSelector:@selector(setParentController:) withObject:parentController];
	[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
	[controller setValue:object];	
	return controller;
}

@end
