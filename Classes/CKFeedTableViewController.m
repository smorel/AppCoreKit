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

- (id)initWithFeedSource:(CKFeedSource*)source controllerFactoryMappings:(NSDictionary*)mappings{
	[super init];
	[self setFeedSource:source controllerFactoryMappings:mappings];
	return self;
}

- (void)setFeedSource:(CKFeedSource*)source{
	[_feedSource release];
	_feedSource = [source retain];
	self.objectController = [[[CKDocumentController alloc]initWithDocument:source.document key:source.objectsKey]autorelease];
	[source release];
}

- (void)setFeedSource:(CKFeedSource*)source controllerFactoryMappings:(NSDictionary*)mappings{
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings];	
	self.feedSource = source;
}

//Faire la poutine de binding sur la dataSource pour afficher le activityIndicator ou le message de empty ...

@end
