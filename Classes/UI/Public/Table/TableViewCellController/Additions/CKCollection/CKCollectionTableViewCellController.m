//
//  CKCollectionTableViewCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollectionTableViewCellController.h"
#import "CKFormBindedCollectionSection_private.h"
#import "CKFeedSource.h"
#import "NSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKCarouselCollectionViewController.h"
#import "CKCollection.h"
#import "CKCollectionTableViewCellController+Style.h"
#import "CKTableViewCellController+Style.h"

#import "CKFormTableViewController.h"
#import "CKFormBindedCollectionSection.h"

#import "CKStyleManager.h"

#define ACTIVITY_INDICATOR_TAG 98634

@interface CKCollectionCellController()
- (void)setContainerController:(CKCollectionViewController*)c;
@end


@implementation CKCollectionTableViewCellController

- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

- (void)setContainerController:(CKCollectionViewController*)c{
    [super setContainerController:c];
    if(self.parentTableView.pagingEnabled){
        self.size = CGSizeMake(-1,-1);
        return;
    }
    self.size = CGSizeMake(320,44);
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	NSMutableDictionary* theStyle = [self controllerStyle];
	
	UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:theStyle.indicatorStyle] autorelease];
	activityIndicator.center = cell.contentView.center;
	activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    activityIndicator.tag = ACTIVITY_INDICATOR_TAG;
	activityIndicator.hidden = YES;
	
	[cell.contentView addSubview:activityIndicator];
    
    
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.backgroundColor = [UIColor clearColor];
}

//FIXME : UGLY TEMPORARY HACK
- (BOOL)forceHidden{
	if([self.containerController isKindOfClass:[CKCarouselCollectionViewController class]])
		return YES;
	else if([self.containerController isKindOfClass:[CKTableViewControllerOld class]]){
		CKTableViewControllerOld* tableViewController = (CKTableViewControllerOld*)self.containerController ;
		return tableViewController.tableView.pagingEnabled;
	}
	return NO;
}

- (void)update:(UITableViewCell*)view{
	if(view == nil)
		return;
	
	CKCollection* collection = (CKCollection*)self.value;
	
    UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[view.contentView viewWithTag:ACTIVITY_INDICATOR_TAG];
	activityIndicator.hidden = [self forceHidden] || !collection.isFetching || view.frame.size.width <= 0 || view.frame.size.height <= 0;
	if(!activityIndicator.hidden){
		[activityIndicator startAnimating];
	}
	else{
		[activityIndicator stopAnimating];
	}
	
	NSMutableDictionary* theStyle = [self controllerStyle];
    
    NSInteger count = [collection count];
    if([self.containerController isKindOfClass:[CKFormTableViewController class]]){
        CKFormTableViewController* form = (CKFormTableViewController*)self.containerController;
        CKFormSectionBase* section = [form sectionAtIndex:self.indexPath.section];
        if([section isKindOfClass:[CKFormBindedCollectionSection class]]){
            CKFormBindedCollectionSection* collectionSection = (CKFormBindedCollectionSection*)section;
            CKCollectionController* collectionController = collectionSection.objectController;
            
            count = (collectionController.maximumNumberOfObjectsToDisplay > 0) ? MIN(collectionController.maximumNumberOfObjectsToDisplay,count) : count;
        }
    }
	
    if(activityIndicator.hidden){
        switch(count){
            case 0:{
                self.text = _(theStyle.noItemsMessage);
                break;
            }
            case 1:{
                self.text = _(theStyle.oneItemMessage);
                break;
            }
            default:{
                self.text = [NSString stringWithFormat:_(theStyle.manyItemsMessage),count];
                break;
            }
        }
    }else{
       self.text = @" ";
    }
}

- (void)internalUpdate:(id)value{
	[self performSelectorOnMainThread:@selector(update:) withObject:self.tableViewCell waitUntilDone:NO];
}

- (void)setupCell:(UITableViewCell *)cell{
	[super setupCell:cell];
	
	CKCollection* collection = (CKCollection*)self.value;
	
	[self update:cell];
	
	[cell beginBindingsContextByRemovingPreviousBindings];
	[collection bind:@"isFetching" target:self action:@selector(internalUpdate:)];
	[collection bind:@"count" target:self action:@selector(internalUpdate:)];
	[cell endBindingsContext];
}

@end
