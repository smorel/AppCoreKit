//
//  CKTableViewCellController+Responder.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController+Responder.h"
#import "CKBindedTableViewController.h"
#import "CKNSObject+Invocation.h"


//CKTableViewCellController+Responder

@implementation CKTableViewCellController(CKResponder)

+ (BOOL)hasResponderAtIndexPath:(NSIndexPath*)indexPath controller:(CKItemViewContainerController*)controller{
    if([controller isKindOfClass:[CKBindedTableViewController class]]){
        CKBindedTableViewController* tableViewController = (CKBindedTableViewController*)controller;
        CKTableViewCellController* cellController = (CKTableViewCellController*)[tableViewController controllerAtIndexPath:indexPath];
        if([cellController hasResponder] == YES)
            return YES;
    }
    else{
        NSAssert(NO,@"CKTableViewCellNextResponder is supported only for CKBindedTableViewController yet");
    }
    return NO;
}


- (NSIndexPath*)findNextResponderWithScrollEnabled:(BOOL)enableScroll{
	if([self.containerController isKindOfClass:[CKTableViewController class]]){
        CKItemViewContainerController* parentController = (CKItemViewContainerController*)self.containerController;
        
		NSIndexPath* indexPath = self.indexPath;
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
            if([CKTableViewCellController hasResponderAtIndexPath:nextIndexPath controller:parentController]){
                return nextIndexPath;
            }
		}
	}
	return nil;
}

- (NSIndexPath*)findPreviousResponderWithScrollEnabled:(BOOL)enableScroll{
	if([self.containerController isKindOfClass:[CKTableViewController class]]){
        CKItemViewContainerController* parentController = (CKItemViewContainerController*)self.containerController;
        
		NSIndexPath* indexPath = self.indexPath;
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
            if([CKTableViewCellController hasResponderAtIndexPath:previousIndexPath controller:parentController]){
                return previousIndexPath;
            }
		}
	}
	return nil;
}


+ (void)activateAfterDelay:(CKTableViewCellController*)controller indexPath:(NSIndexPath*)indexPath{
	if([controller.containerController isKindOfClass:[CKBindedTableViewController class]]){
		CKBindedTableViewController* tableViewController = (CKBindedTableViewController*)controller.containerController;
	
		CKTableViewCellController* controllerNew = (CKTableViewCellController*)[tableViewController controllerAtIndexPath:indexPath];
		if(controllerNew != nil){
            UIView* responder = [controllerNew nextResponder:nil];
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

- (BOOL)activateNextResponder{
	NSIndexPath* nextIndexPath = [self findNextResponderWithScrollEnabled:YES];
	if(nextIndexPath == nil)
		return NO;
	[CKTableViewCellController activateResponderAtIndexPath:nextIndexPath controller:self];
	return YES;
}


- (BOOL)needsNextKeyboard{
	NSIndexPath* nextIndexPath = [self findNextResponderWithScrollEnabled:NO];
	if(nextIndexPath == nil)
		return NO;
	return YES;
}


- (BOOL)activatePreviousResponder{
    NSIndexPath* previousIndexPath = [self findPreviousResponderWithScrollEnabled:YES];
	if(previousIndexPath == nil)
		return NO;
	[CKTableViewCellController activateResponderAtIndexPath:previousIndexPath controller:self];
	return YES;
}

- (BOOL)needsPreviousKeyboard{
    NSIndexPath* previousIndexPath = [self findPreviousResponderWithScrollEnabled:NO];
	if(previousIndexPath == nil)
		return NO;
	return YES;
}

- (BOOL)hasResponder{
    return NO;
}

- (void)becomeFirstResponder{
    
}

- (UIView*)nextResponder:(UIView*)view{
    return nil;
}

@end
