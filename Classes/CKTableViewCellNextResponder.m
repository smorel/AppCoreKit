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
#import "CKPropertyGridCellController.h"


@implementation CKTableViewCellNextResponder

+ (NSIndexPath*)findNextTextController:(CKTableViewCellController*)controller enableScroll:(BOOL)enableScroll{
	if([controller.parentController isKindOfClass:[CKTableViewController class]]){
        CKItemViewContainerController* parentController = (CKItemViewContainerController*)controller.parentController;
		UITableView* tableView = [controller parentTableView];
		NSIndexPath* indexPath = controller.indexPath;
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		
		NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
		while(nextIndexPath != nil){
			NSInteger rowCountForSection = [parentController numberOfObjectsForSection:section];
			if((NSInteger)nextIndexPath.row >= (rowCountForSection - 1)){
				NSInteger sectionCount = [tableView numberOfSections];
				if((NSInteger)nextIndexPath.section >= (sectionCount - 1)){
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
                    CKTableViewCellController* cellController = (CKTableViewCellController*)[tableViewController controllerAtIndexPath:nextIndexPath];
                    //This is a hack because the system do not works well ...
                    if(cellController && [cellController isKindOfClass:[CKPropertyGridCellController class]]){
                        CKPropertyGridCellController* pcell = (CKPropertyGridCellController*)cellController;
                        if(!pcell.readOnly){
                            if([factoryItem.controllerClass hasAccessoryResponderWithValue:object] == YES)
                                return nextIndexPath;
                        }
                    }
                    else if([factoryItem.controllerClass hasAccessoryResponderWithValue:object] == YES)
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
	if([controller.parentController isKindOfClass:[CKObjectTableViewController class]]){
		CKObjectTableViewController* tableViewController = (CKObjectTableViewController*)controller.parentController;
		
		UITableView* tableView = [controller parentTableView];
		UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
	
		CKTableViewCellController* controllerNew = (CKTableViewCellController*)[tableViewController controllerAtIndexPath:indexPath];
		if(controllerNew != nil){
            UIResponder* responder = [[controllerNew class]responderInView:tableViewCell];
            [responder becomeFirstResponder];
        }
	}
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
