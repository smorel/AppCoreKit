//
//  CKFeedCarouselViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-12.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedCarouselViewController.h"
#import "CKDocumentController.h"


@implementation CKFeedCarouselViewController
@synthesize feedSource = _feedSource;

- (void)dealloc{
	[_feedSource release];
	_feedSource = nil;
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
	[self.objectController setDisplayFeedSourceCell:NO];
	[_feedSource fetchNextItems:10];
}

- (void)setFeedSource:(CKFeedSource*)source mappings:(NSDictionary*)mappings styles:(NSDictionary*)styles{
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings withStyles:styles];	
	self.feedSource = source;
}

@end
