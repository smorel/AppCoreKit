//
//  CKDocumentCollection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"
#import "CKFeedSource.h"
#import "CKDocumentStorage.h"

@interface CKDocumentCollection : CKModelObject<CKFeedSourceDelegate> {
	CKFeedSource* _feedSource;
	id _storage;//<CKDocumentStorage>
	BOOL _autosave;
	id _delegate;
	NSInteger _count;
}

@property (nonatomic,retain) CKFeedSource* feedSource;
@property (nonatomic,retain) id storage;
@property (nonatomic,assign) BOOL autosave;
@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) NSInteger count;

- (id)initWithFeedSource:(CKFeedSource*)source;
- (id)initWithFeedSource:(CKFeedSource*)source withStorage:(id)storage;
- (id)initWithStorage:(id)storage;

- (NSArray*)allObjects;
- (BOOL)containsObject:(id)object;
- (id)objectAtIndex:(NSInteger)index;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet;
- (void)removeAllObjects;
- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other;

- (BOOL)load;
- (BOOL)save;

- (void)addObserver:(id)object;
- (void)removeObserver:(id)object;
- (void)fetchRange:(NSRange)range;

- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate;

@end

@protocol CKDocumentCollectionDelegate
@optional
- (void)documentCollection:(CKDocumentCollection *)collection didFetchItems:(NSArray *)items atRange:(NSRange)range;
- (void)documentCollection:(CKDocumentCollection *)collection fetchDidFailWithError:(NSError *)error;
//
- (void)documentCollectionDidLoad:(CKDocumentCollection*)collection;
- (void)documentCollectionDidSave:(CKDocumentCollection*)collection;
- (void)documentCollectionDidFailLoading:(CKDocumentCollection*)collection;
- (void)documentCollectionDidFailSaving:(CKDocumentCollection*)collection;
//very global delegate selector : could be splitted in several more precise functions
- (void)documentCollectionDidChange:(CKDocumentCollection*)collection;
@end
