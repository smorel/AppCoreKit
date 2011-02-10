//
//  CKFeedSource.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedSource.h"


@implementation CKFeedSource

@synthesize delegate = _delegate;
@synthesize items = _items;
@synthesize currentIndex = _currentIndex;
@synthesize limit = _limit;
@synthesize hasMore = _hasMore;
@synthesize isFetching = _isFetching;

#pragma mark Initialization

- (id)init {
	if (self = [super init]) {
		[self reset];
	}
	return self;
}

- (void)dealloc {
	[_items release]; 
	_items = nil;
	_delegate = nil;
	[super dealloc];
}

#pragma mark Public API

- (BOOL)fetchNextItems:(NSUInteger)batchSize {
	return NO;
}

- (void)cancelFetch {
	_fetching = NO;
	return;
}

- (void)reset {
	[_items release];
	_items = [[NSMutableArray alloc] init];
	_currentIndex = 0;
	_hasMore = YES;
	_fetching = NO;
}

#pragma mark KVO

- (void)addItems:(NSArray *)theItems {
	NSArray *newItems = theItems;
	
	if ((_limit > 0) && (_items.count + theItems.count) > _limit) {
		newItems = [theItems subarrayWithRange:NSMakeRange(0, abs(_limit - _items.count))];
		_hasMore = NO;
	}
	
	if([newItems count] <= 0)
		return;
	
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_currentIndex, [newItems count])];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"items"];
    [_items addObjectsFromArray:newItems];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"items"];
}

@end
