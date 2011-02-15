//
//  CKFeedSource.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedSource.h"

@interface CKFeedSource ()
@property (nonatomic, retain, readwrite) id<CKModelObjectsProtocol> externalModel;
@property (nonatomic, retain, readwrite) NSString *externalModelKey;
@end

@implementation CKFeedSource

@synthesize delegate = _delegate;
@synthesize currentIndex = _currentIndex;
@synthesize limit = _limit;
@synthesize hasMore = _hasMore;
@synthesize isFetching = _isFetching;

@synthesize items = _items;
@synthesize externalModel = _externalModel;
@synthesize externalModelKey = _externalModelKey;
#pragma mark Initialization

- (id)initWithExternalModel:(id<CKModelObjectsProtocol>)model forKey:(NSString*)key{
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
	[_items release];
	if(self.externalModel == nil){
		_items = [[NSMutableArray alloc] init];
	}
	_currentIndex = 0;
	_hasMore = YES;
	_fetching = NO;
}

- (NSArray*)items{
	if(_externalModel == nil)
		return _items;
	else{
		return [_externalModel objectsForKey:_externalModelKey];
	}
}

- (void)registerAsModelObserver:(id)object{
	if(_externalModel == nil){
		[self addObserver:object
					 forKeyPath:@"items"
						options:(NSKeyValueObservingOptionNew)
						context:nil];
	}
	else{
		[_externalModel registerAsObserver:object forKey:_externalModelKey];
	}
}

- (void)unregisterAsModelObserver:(id)object{
	if(_externalModel == nil){
		[self removeObserver:object forKeyPath:@"items"];
	}
	else{
		[_externalModel unregisterAsObserver:object forKey:_externalModelKey];	
	}
}

#pragma mark KVO

- (void)addItems:(NSArray *)theItems {
	NSArray *newItems = theItems;
	
	if ((_limit > 0) && (_items.count + theItems.count) > _limit) {
		newItems = [theItems subarrayWithRange:NSMakeRange(0, abs(_limit - _items.count))];
		_hasMore = NO;
	}
	
	if(self.externalModel == nil){
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_currentIndex, [newItems count])];
		[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"items"];
		[_items addObjectsFromArray:newItems];
		[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"items"];
	}
	else{
		[_externalModel addObjects:newItems forKey:_externalModelKey];
	}
}

@end
