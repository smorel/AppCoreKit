//
//  CKTableViewCellNextResponder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellNextResponder.h"
#import "CKObjectTableViewController.h"



@implementation CKTableViewCellNextResponder

+ (NSIndexPath*)findNextTextController:(CKTableViewCellController*)controller enableScroll:(BOOL)enableScroll{
	if([controller.parentController isKindOfClass:[CKTableViewController class]]){
		UITableView* tableView = controller.parentController.tableView;
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
			
			
			if(enableScroll){
				BOOL isVisible = NO;
				NSArray* visibleCells = [tableView visibleCells];
				for (UITableViewCell *cell in visibleCells) {
					NSIndexPath *visibleIndexPath = [tableView indexPathForCell:cell];
					if([visibleIndexPath isEqual:nextIndexPath]){
						isVisible = YES;
						break;
					}
				}
				
				if(isVisible == NO){
					[tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
				}
			}
			
			
			//get the value at indexpath and the controller type and call + (BOOL)hasAccessoryResponderWithValue:(id)object
			if([controller.parentController isKindOfClass:[CKObjectTableViewController class]]){
				CKObjectTableViewController* tableViewController = (CKObjectTableViewController*)controller.parentController;
				Class controllerClass = [tableViewController.controllerFactory controllerClassForIndexPath:nextIndexPath];
				if([controllerClass respondsToSelector:@selector(hasAccessoryResponderWithValue:)]){
					id object = [tableViewController.objectController objectAtIndexPath:nextIndexPath];
					if([controllerClass hasAccessoryResponderWithValue:object] == YES)
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

+ (BOOL)setNextResponder:(CKTableViewCellController*)controller{
	NSIndexPath* nextIndexPath = [CKTableViewCellNextResponder findNextTextController:controller enableScroll:YES];
	if(nextIndexPath == nil)
		return NO;
	
	UITableView* tableView = controller.parentController.tableView;
	UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:nextIndexPath];
	UITextField* textfield = (UITextField*)tableViewCell.accessoryView;
	[textfield becomeFirstResponder];
	return YES;
}

+ (BOOL)needsNextKeyboard:(CKTableViewCellController*)controller{
	NSIndexPath* nextIndexPath = [CKTableViewCellNextResponder findNextTextController:controller enableScroll:NO];
	if(nextIndexPath == nil)
		return NO;
	
	return YES;
}

@end
