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

+ (BOOL)hasResponderAtIndexPath:(NSIndexPath*)indexPath controller:(CKTableViewCellController*)controller{
    //get the value at indexpath and the controller type and call + (BOOL)hasAccessoryResponderWithValue:(id)object
    if([controller.parentController isKindOfClass:[CKObjectTableViewController class]]){
        CKObjectTableViewController* tableViewController = (CKObjectTableViewController*)controller.parentController;
        CKObjectViewControllerFactoryItem* factoryItem = [tableViewController.controllerFactory factoryItemAtIndexPath:indexPath];
        if([factoryItem.controllerClass respondsToSelector:@selector(hasAccessoryResponderWithValue:)]){
            id object = [tableViewController.objectController objectAtIndexPath:indexPath];
            CKTableViewCellController* cellController = (CKTableViewCellController*)[tableViewController controllerAtIndexPath:indexPath];
            //This is a hack because the system do not works well ...
            if(cellController && [cellController isKindOfClass:[CKPropertyGridCellController class]]){
                CKPropertyGridCellController* pcell = (CKPropertyGridCellController*)cellController;
                if(!pcell.readOnly){
                    if([factoryItem.controllerClass hasAccessoryResponderWithValue:object] == YES)
                        return YES;
                }
            }
            else if([factoryItem.controllerClass hasAccessoryResponderWithValue:object] == YES)
                return YES;
        }
    }
    else{
        NSAssert(NO,@"CKTableViewCellNextResponder is supported only for CKObjectTableViewController yet");
    }
    return NO;
}

+ (NSIndexPath*)findNextTextController:(CKTableViewCellController*)controller enableScroll:(BOOL)enableScroll{
	if([controller.parentController isKindOfClass:[CKTableViewController class]]){
        CKItemViewContainerController* parentController = (CKItemViewContainerController*)controller.parentController;
		NSIndexPath* indexPath = controller.indexPath;
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		
		NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
		while(nextIndexPath != nil){
			NSInteger rowCountForSection = [parentController numberOfObjectsForSection:section];
			if((NSInteger)nextIndexPath.row >= (rowCountForSection - 1)){
				NSInteger sectionCount = [parentController numberOfSections];
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
            if([CKTableViewCellNextResponder hasResponderAtIndexPath:nextIndexPath controller:controller]){
                return nextIndexPath;
            }
		}
	}
	return nil;
}

+ (NSIndexPath*)findPreviousTextController:(CKTableViewCellController*)controller enableScroll:(BOOL)enableScroll{
	if([controller.parentController isKindOfClass:[CKTableViewController class]]){
        CKItemViewContainerController* parentController = (CKItemViewContainerController*)controller.parentController;
		NSIndexPath* indexPath = controller.indexPath;
		NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		
		NSIndexPath* previousIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
		while(previousIndexPath != nil){
			if(row-1 < 0){
				if((NSInteger)section == 0){
					return nil;
				}
				section--;
				row = [parentController numberOfObjectsForSection:section] - 1;
			}
			else{
				row--;
			}
			
			previousIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if([CKTableViewCellNextResponder hasResponderAtIndexPath:previousIndexPath controller:controller]){
                return previousIndexPath;
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
            UIView* responder = [[controllerNew class]responderInView:tableViewCell];
            if(responder && [responder isKindOfClass:[UIResponder class]]){
                [responder becomeFirstResponder];
            }
            [controllerNew becomeFirstResponder];
        }
	}
}

+ (void)activateResponderAtIndexPath:(NSIndexPath*)indexPath controller:(CKTableViewCellController*)controller{
	UITableView* tableView = [controller parentTableView];
	[tableView scrollToRowAtIndexPath:indexPath
					 atScrollPosition:UITableViewScrollPositionNone
							 animated:YES];
	
	UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
	if(tableViewCell != nil){
		[[self class] activateAfterDelay:controller indexPath:indexPath];
	}
	else{
		[[self class]performSelector:@selector(activateAfterDelay:indexPath:) withObject:controller withObject:indexPath afterDelay:0.3];
	} 
}

+ (BOOL)activateNextResponderFromController:(CKTableViewCellController*)controller{
	NSIndexPath* nextIndexPath = [CKTableViewCellNextResponder findNextTextController:controller enableScroll:YES];
	if(nextIndexPath == nil)
		return NO;
	[CKTableViewCellNextResponder activateResponderAtIndexPath:nextIndexPath controller:controller];
	return YES;
}


+ (BOOL)needsNextKeyboard:(CKTableViewCellController*)controller{
	NSIndexPath* nextIndexPath = [CKTableViewCellNextResponder findNextTextController:controller enableScroll:NO];
	if(nextIndexPath == nil)
		return NO;
	return YES;
}


+ (BOOL)activatePreviousResponderFromController:(CKTableViewCellController*)controller{
    NSIndexPath* previousIndexPath = [CKTableViewCellNextResponder findPreviousTextController:controller enableScroll:YES];
	if(previousIndexPath == nil)
		return NO;
	[CKTableViewCellNextResponder activateResponderAtIndexPath:previousIndexPath controller:controller];
	return YES;
}

+ (BOOL)needsPreviousKeyboard:(CKTableViewCellController*)controller{
    NSIndexPath* previousIndexPath = [CKTableViewCellNextResponder findPreviousTextController:controller enableScroll:NO];
	if(previousIndexPath == nil)
		return NO;
	return YES;
}

@end
