//
//  CKFeedSourceViewCellController.m
//  NFB
//
//  Created by Sebastien Morel on 11-03-23.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedSourceViewCellController.h"
#import <CloudKit/CKFeedSource.h>
#import <CloudKit/CKNSObject+Bindings.h>
#import <CloudKit/CKLocalization.h>
#import "CKNSDictionary+TableViewAttributes.h"

#define ActivityIndicatorTag 1
#define LabelTag 2

@implementation CKFeedSourceViewCellController

- (void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

- (UITableViewCell *)loadCell{
	UITableViewCell *cell = [self cellWithStyle:UITableViewCellStyleDefault];
	
	UIView* view = [[[UIView alloc]initWithFrame:cell.contentView.bounds]autorelease];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor clearColor];
	
	UIActivityIndicatorView* activityView = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]autorelease];
	activityView.frame = CGRectMake(view.bounds.size.width / 2 - activityView.bounds.size.width /2,
									view.bounds.size.height / 2 - activityView.bounds.size.height / 2,
									activityView.bounds.size.width,activityView.bounds.size.height);
	activityView.tag = ActivityIndicatorTag;
	[view addSubview:activityView];
	
	UILabel* label = [[[UILabel alloc]initWithFrame:view.bounds]autorelease];
	label.textAlignment = UITextAlignmentCenter;
	label.tag = LabelTag;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
	[view addSubview:label];
	
	[cell.contentView addSubview:view];
	
	return cell;
}

- (void)update:(UIView*)view{
	CKFeedSource* source = (CKFeedSource*)self.value;
	
	UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[view viewWithTag:ActivityIndicatorTag];
	activityIndicator.hidden = !source.hasMore || view.frame.size.width <= 0|| view.frame.size.height <= 0;
	if(source.hasMore){
		[activityIndicator startAnimating];
	}
	else{
		[activityIndicator stopAnimating];
	}
	
	UILabel* label = (UILabel*)[view viewWithTag:LabelTag];
	label.hidden = source.hasMore;	
	label.text = [NSString stringWithFormat:@"%d %@",source.currentIndex,_(@"Objects")];
}

- (void)internalUpdate:(id)value{
	[self update:self.tableViewCell];
}

- (void)setupCell:(UITableViewCell *)cell{
	[super setupCell:cell];
	
	CKFeedSource* source = (CKFeedSource*)self.value;
	[self update:cell.contentView];
	
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

@end
