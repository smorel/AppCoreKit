//
//  CKFeedSource.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedSource.h"

@interface CKFeedSource ()
@property (nonatomic, retain, readwrite) id<CKDocument> externalModel;
@property (nonatomic, retain, readwrite) NSString *externalModelKey;
@end

@implementation CKFeedSource

@synthesize delegate = _delegate;
@synthesize currentIndex = _currentIndex;
@synthesize limit = _limit;
@synthesize hasMore = _hasMore;
@synthesize isFetching = _isFetching;

@synthesize externalModel = _externalModel;
@synthesize externalModelKey = _externalModelKey;
#pragma mark Initialization

- (id)initWithExternalModel:(id<CKDocument>)model forKey:(NSString*)key{
	if (self = [super init]) {
		self.externalModel = model;
		self.externalModelKey = key;
		[self reset];
		_currentIndex = [self.items count];
	}
	return self;
}

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
	self.externalModel = nil;
	self.externalModelKey = nil;
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
	_currentIndex = 0;
	_hasMore = YES;
	_fetching = NO;
}

- (NSArray*)items{
	NSAssert(_externalModel,@"Model is not assigned");
	return [_externalModel objectsForKey:_externalModelKey];
}

- (void)addObserver:(id)object{
	NSAssert(_externalModel,@"Model is not assigned");
	[_externalModel addObserver:object forKey:_externalModelKey];
}

- (void)removeObserver:(id)object{
	NSAssert(_externalModel,@"Model is not assigned");
	[_externalModel removeObserver:object forKey:_externalModelKey];	
}

#pragma mark KVO

- (void)addItems:(NSArray *)theItems {
	NSArray *newItems = theItems;
	
	if ((_limit > 0) && (_items.count + theItems.count) > _limit) {
		newItems = [theItems subarrayWithRange:NSMakeRange(0, abs(_limit - _items.count))];
		_hasMore = NO;
	}
	
	NSAssert(_externalModel,@"Model is not assigned");
	[_externalModel addObjects:newItems forKey:_externalModelKey];
}

@end
