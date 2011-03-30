//
//  CKFeedTableViewController.m
//  NFB
//
//  Created by Sebastien Morel on 11-03-23.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedTableViewController.h"
#import <CloudKit/CKDocumentController.h>


@implementation CKFeedTableViewController
@synthesize feedSource = _feedSource;
@synthesize emptyMessage = _emptyMessage;

- (void)dealloc{
	[_feedSource release];
	_feedSource = nil;
	[_emptyMessage release];
	_emptyMessage = nil;
	[super dealloc];
}

- (id)initWithFeedSource:(CKFeedSource*)source mappings:(NSDictionary*)mappings styles:(NSDictionary*)styles{
	[super init];
	[self setFeedSource:source mappings:mappings styles:styles];
	return self;
}

- (void)setFeedSource:(CKFeedSource*)source{
	[_feedSource release];
	_feedSource = [source retain];
	self.objectController = [[[CKDocumentController alloc]initWithDocument:source.document key:source.objectsKey]autorelease];
}

- (void)setFeedSource:(CKFeedSource*)source mappings:(NSDictionary*)mappings styles:(NSDictionary*)styles{
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings withStyles:styles];	
	self.feedSource = source;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if(_feedSource){
		[_feedSource fetchNextItems:10];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	if(_feedSource){
		[_feedSource cancelFetch];
	}
}

@end
