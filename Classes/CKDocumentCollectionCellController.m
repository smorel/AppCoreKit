//
//  CKDocumentCollectionViewCellController.m
//  NFB
//
//  Created by Sebastien Morel on 11-03-23.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentCollectionCellController.h"
#import <CloudKit/CKFeedSource.h>
#import <CloudKit/CKNSObject+Bindings.h>
#import <CloudKit/CKLocalization.h>
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKObjectCarouselViewController.h"
#import "CKDocumentCollection.h"

#import "CKStyleManager.h"

/*
static CKDocumentCollectionCellControllerStyle* CKDocumentCollectionCellControllerStyleDefaultStyle = nil;

@implementation CKDocumentCollectionCellControllerStyle
@synthesize noItemsMessage, oneItemMessage, manyItemsMessage, backgroundColor, textColor, indicatorStyle;

+ (CKDocumentCollectionCellControllerStyle*)defaultStyle{
	if(CKDocumentCollectionCellControllerStyleDefaultStyle == nil){
		[CKDocumentCollectionCellControllerStyleDefaultStyle = [CKDocumentCollectionCellControllerStyle alloc]init];
		CKDocumentCollectionCellControllerStyleDefaultStyle.noItemsMessage = @"No Object";
		CKDocumentCollectionCellControllerStyleDefaultStyle.oneItemMessage = @"1 Object";
		CKDocumentCollectionCellControllerStyleDefaultStyle.manyItemsMessage = @"Objects";
		CKDocumentCollectionCellControllerStyleDefaultStyle.backgroundColor = [UIColor clearColor];
		CKDocumentCollectionCellControllerStyleDefaultStyle.textColor = [UIColor whiteColor];
		CKDocumentCollectionCellControllerStyleDefaultStyle.indicatorStyle = UIActivityIndicatorViewStyleWhite;
	}
	return CKDocumentCollectionCellControllerStyleDefaultStyle;
}

@end
*/

#define ActivityIndicatorTag 1
#define LabelTag 2

@implementation CKDocumentCollectionViewCellController

- (void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	NSDictionary* controllerStyle = [self controllerStyle];
	//SEB : TODO !!!! use controllerStyle
	
	UIView* view = [[[UIView alloc] initWithFrame:cell.contentView.bounds] autorelease];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	NSAssert(NO,@"TODO");
	/*
	UIActivityIndicatorView* activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:theStyle.indicatorStyle] autorelease];
	activityView.center = cell.center;
	activityView.tag = ActivityIndicatorTag;
	activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	activityView.hidden = YES;
	
	[view addSubview:activityView];
	
	UILabel* label = [[[UILabel alloc] initWithFrame:view.bounds] autorelease];
	label.textAlignment = UITextAlignmentCenter;
	label.tag = LabelTag;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = theStyle.textColor;
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view addSubview:label];
	*/
	
	[cell.contentView addSubview:view];
}

- (void)update:(UIView*)view{
	CKDocumentCollection* collection = (CKDocumentCollection*)self.value;
	CKFeedSource* source = collection.feedSource;
	
	UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[view viewWithTag:ActivityIndicatorTag];
	BOOL forceHidden = [self.parentController isKindOfClass:[CKObjectCarouselViewController class]] || self.parentController.tableView.pagingEnabled; //FIXME : UGLY TEMPORARY HACK
	activityIndicator.hidden = forceHidden || !source.isFetching || !source.hasMore || view.frame.size.width <= 0 || view.frame.size.height <= 0;
	if(!activityIndicator.hidden){
		[activityIndicator startAnimating];
	}
	else{
		[activityIndicator stopAnimating];
	}
	
	NSDictionary* controllerStyle = [self controllerStyle];
	//SEB : TODO !!!! use controllerStyle
	
	NSAssert(NO,@"TODO");
	
	/*UILabel* label = (UILabel*)[view viewWithTag:LabelTag];
	label.hidden = !activityIndicator.hidden;	
	switch([collection count]){
		case 0:{
			label.text = theStyle.noItemsMessage;
			break;
		}
		case 1:{
			label.text = theStyle.oneItemMessage;
			break;
		}
		default:{
			label.text = [NSString stringWithFormat:@"%d %@",[collection count],_(theStyle.manyItemsMessage)];
			break;
		}
	}*/
}

- (void)internalUpdate:(id)value{
	[self update:self.tableViewCell];
}

- (void)setupCell:(UITableViewCell *)cell{
	[super setupCell:cell];
	self.selectable = NO;
	
	CKDocumentCollection* collection = (CKDocumentCollection*)self.value;
	CKFeedSource* source = collection.feedSource;
	
	[self update:cell.contentView];
	
	UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[cell.contentView viewWithTag:ActivityIndicatorTag];
	BOOL forceHidden = [self.parentController isKindOfClass:[CKObjectCarouselViewController class]] || self.parentController.tableView.pagingEnabled; //FIXME : UGLY TEMPORARY HACK
	activityIndicator.hidden = activityIndicator.hidden || forceHidden;
	
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[source bind:@"isFetching" target:self action:@selector(internalUpdate:)];
	[source bind:@"hasMore" target:self action:@selector(internalUpdate:)];
	[source bind:@"currentIndex" target:self action:@selector(internalUpdate:)];
	[NSObject endBindingsContext];
}

+ (NSValue*)rowSizeForObject:(id)object withParams:(NSDictionary*)params{
	if([params pagingEnabled])
		return [NSValue valueWithCGSize:CGSizeMake(-1,-1)];
	return [NSValue valueWithCGSize:CGSizeMake(320,44)];
}


+ (CKTableViewCellFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKTableViewCellFlagNone;
}

@end
