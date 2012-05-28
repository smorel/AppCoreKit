//
//  CKCollectionCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-23.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollectionCellController.h"
#import "CKFeedSource.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKBindedCarouselViewController.h"
#import "CKCollection.h"
#import "CKCollectionCellController+Style.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKTableViewCellController+Style.h"

#import "CKStyleManager.h"

#define ACTIVITY_INDICATOR_TAG 98634

@interface CKItemViewController()
- (void)setContainerController:(CKItemViewContainerController*)c;
@end


@implementation CKCollectionCellController

- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

- (void)setContainerController:(CKItemViewContainerController*)c{
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
	activityIndicator.center = cell.center;
	activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    activityIndicator.tag = ACTIVITY_INDICATOR_TAG;
	activityIndicator.hidden = YES;
	
	[cell.contentView addSubview:activityIndicator];
}

//FIXME : UGLY TEMPORARY HACK
- (BOOL)forceHidden{
	if([self.containerController isKindOfClass:[CKBindedCarouselViewController class]])
		return YES;
	else if([self.containerController isKindOfClass:[CKTableViewController class]]){
		CKTableViewController* tableViewController = (CKTableViewController*)self.containerController ;
		return tableViewController.tableView.pagingEnabled;
	}
	return NO;
}

- (void)update:(UITableViewCell*)view{
	if(view == nil)
		return;
	
	CKCollection* collection = (CKCollection*)self.value;
	
    UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[view viewWithTag:ACTIVITY_INDICATOR_TAG];
	activityIndicator.hidden = [self forceHidden] || !collection.isFetching || view.frame.size.width <= 0 || view.frame.size.height <= 0;
	if(!activityIndicator.hidden){
		[activityIndicator startAnimating];
	}
	else{
		[activityIndicator stopAnimating];
	}
	
	NSMutableDictionary* theStyle = [self controllerStyle];
	
    view.textLabel.textAlignment = UITextAlignmentCenter;
	view.textLabel.text = @" ";
    if(activityIndicator.hidden){
        switch([collection count]){
            case 0:{
                view.textLabel.text = _(theStyle.noItemsMessage);
                break;
            }
            case 1:{
                view.textLabel.text = _(theStyle.oneItemMessage);
                break;
            }
            default:{
                view.textLabel.text = [NSString stringWithFormat:_(theStyle.manyItemsMessage),[collection count]];
                break;
            }
        }
    }
}

- (void)internalUpdate:(id)value{
	[self update:self.tableViewCell];
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
