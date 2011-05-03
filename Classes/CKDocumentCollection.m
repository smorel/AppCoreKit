//
//  CKDocumentCollection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentCollection.h"


@implementation CKDocumentCollection
@synthesize feedSource = _feedSource;
@synthesize storage = _storage;
@synthesize autosave = _autosave;
@synthesize delegate = _delegate;


- (id)initWithFeedSource:(CKFeedSource*)source{
	[super init];
	self.feedSource = source;
	source.delegate = self;
	self.autosave = NO;
	return self;
}

- (id)initWithFeedSource:(CKFeedSource*)source withStorage:(id)theStorage{
	[self initWithFeedSource:source];
	self.storage = theStorage;
	return self;
}

- (void)feedSourceMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.serializable = NO;
}

- (void)storageMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.serializable = NO;
}

- (void)delegateMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.serializable = NO;
}

- (NSInteger)count{
	return 0;
}

- (NSArray*)allObjects{
	NSAssert(NO,@"Abstract Implementation");
	return nil;
}

- (id)objectAtIndex:(NSInteger)index{
	NSAssert(NO,@"Abstract Implementation");
	return nil;
}

- (void)addObjectsFromArray:(NSArray *)otherArray{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
	NSAssert(NO,@"Abstract Implementation");
}
			 
- (void)removeObjectsInArray:(NSArray *)otherArray{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)removeAllObjects{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)addObserver:(id)object{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)removeObserver:(id)object{
	NSAssert(NO,@"Abstract Implementation");
}

- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate{
	NSAssert(NO,@"Abstract Implementation");
	return nil;
}

- (void)fetchRange:(NSRange)range{
	if(_feedSource == nil)
		return;
	//adjust range to existing objects
	NSInteger count = [self count];
	NSInteger requested = range.location + range.length;
	if(requested > count){
		[_feedSource fetchRange:NSMakeRange(count, requested - count)];
	}
}

- (void)feedSource:(CKFeedSource *)feedSource didFetchItems:(NSArray *)items range:(NSRange)range{
	NSAssert(feedSource == _feedSource,@"Not registered on the right feedSource");
	[self insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

- (BOOL)load{
	if(_storage == nil)
		return NO;
	
	if( [_storage load:self] ){
		if(_delegate && [_delegate respondsToSelector:@selector(documentCollectionDidLoad:)]){
			[_delegate documentCollectionDidLoad:self];
		}
		return YES;
	}
	if(_delegate && [_delegate respondsToSelector:@selector(documentCollectionDidFailLoading:)]){
		[_delegate documentCollectionDidFailLoading:self];
	}
	return NO;
}

- (BOOL)save{
	if(_storage == nil)
		return NO;
	
	if( [_storage save:self] ){
		if(_delegate && [_delegate respondsToSelector:@selector(documentCollectionDidSave:)]){
			[_delegate documentCollectionDidSave:self];
		}
		return YES;
	}
	if(_delegate && [_delegate respondsToSelector:@selector(documentCollectionDidFailSaving:)]){
		[_delegate documentCollectionDidFailSaving:self];
	}
	return NO;
}

@end
