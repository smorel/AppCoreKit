//
//  CKTableViewCellNextResponder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellNextResponder.h"
#import "CKObjectTableViewController.h"
#import "CKNSObject+Invocation.h"


@implementation CKTableViewCellNextResponder

+ (NSIndexPath*)findNextTextController:(CKTableViewCellController*)controller enableScroll:(BOOL)enableScroll{
	if([controller.parentController isKindOfClass:[CKTableViewController class]]){
		UITableView* tableView = [controller parentTableView];
		NSIndexPath* indexPath = controller.indexPath;
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		
		NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
		while(nextIndexPath != nil){
			NSInteger rowCountForSection = [tableView numberOfRowsInSection:section];
			if(nextIndexPath.row >= rowCountForSection - 1){
				NSInteger sectionCount = [tableView numberOfSections];
				if(nextIndexPath.section >= sectionCount - 1){
					return nil;
				}
				section++;
				row = 0;
			}
			else{
				row++;
			}
			
			nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];

			//get the value at indexpath and the controller type and call + (BOOL)hasAccessoryResponderWithValue:(id)object
			if([controller.parentController isKindOfClass:[CKObjectTableViewController class]]){
				CKObjectTableViewController* tableViewController = (CKObjectTableViewController*)controller.parentController;
				CKObjectViewControllerFactoryItem* factoryItem = [tableViewController.controllerFactory factoryItemAtIndexPath:nextIndexPath];
				if([factoryItem.controllerClass respondsToSelector:@selector(hasAccessoryResponderWithValue:)]){
					id object = [tableViewController.objectController objectAtIndexPath:nextIndexPath];
					if([factoryItem.controllerClass hasAccessoryResponderWithValue:object] == YES)
						return nextIndexPath;
				}
			}
			else{
				NSAssert(NO,@"CKTableViewCellNextResponder is supported only for CKObjectTableViewController yet");
			}
		}
	}
	return nil;
}


+ (void)activateAfterDelay:(CKTableViewCellController*)controller indexPath:(NSIndexPath*)indexPath{
	UITableView* tableView = [controller parentTableView];
	UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
	UIResponder* responder = [[controller class]responderInView:tableViewCell];
	[responder becomeFirstResponder];
}

+ (BOOL)activateNextResponderFromController:(CKTableViewCellController*)controller{
	NSIndexPath* nextIndexPath = [CKTableViewCellNextResponder findNextTextController:controller enableScroll:YES];
	if(nextIndexPath == nil)
		return NO;
	
	UITableView* tableView = [controller parentTableView];
	[tableView scrollToRowAtIndexPath:nextIndexPath
					 atScrollPosition:UITableViewScrollPositionNone
							 animated:YES];
	
	UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:nextIndexPath];
	if(tableViewCell != nil){
		[[self class] activateAfterDelay:controller indexPath:nextIndexPath];
	}
	else{
		[[self class]performSelector:@selector(activateAfterDelay:indexPath:) withObject:controller withObject:nextIndexPath afterDelay:0.3];
	}
	return YES;
}


+ (BOOL)needsNextKeyboard:(CKTableViewCellController*)controller{
	NSIndexPath* nextIndexPath = [CKTableViewCellNextResponder findNextTextController:controller enableScroll:NO];
	if(nextIndexPath == nil)
		return NO;
	
	return YES;
}

@end
