//
//  CKFeedSource.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedSource.h"
#import "CKNSObject+Invocation.h"

@interface CKFeedSource ()
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) NSRange range;
@end

@implementation CKFeedSource

@synthesize delegate = _delegate;
@synthesize hasMore = _hasMore;
@synthesize isFetching = _isFetching;
@synthesize range = _range;

#pragma mark Initialization

-(void)postInit{
}

- (id)init {
	if (self = [super init]) {
		[self reset];
		[self postInit];
	}
	return self;
}

- (void)dealloc {
	_delegate = nil;
	[super dealloc];
}

#pragma mark Public API

- (BOOL)fetchRange:(NSRange)theRange {
	self.hasMore = NO;
	self.range = theRange;
	return NO;
}

- (void)cancelFetch {
	self.isFetching = NO;
	return;
}

- (void)reset {
	self.hasMore = YES;
	self.isFetching = NO;
}

#pragma mark KVO

- (void)addItems:(NSArray *)theItems {
	if(_delegate && [_delegate respondsToSelector:@selector(feedSource:didFetchItems:range:)]){
		[_delegate feedSource:self didFetchItems:theItems range:NSMakeRange(self.range.location, theItems.count)];
	}
	self.hasMore = (theItems.count >= self.range.length);
}

@end
