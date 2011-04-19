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
}

@property (nonatomic,retain) CKFeedSource* feedSource;
@property (nonatomic,retain) id storage;
@property (nonatomic,assign) BOOL autosave;
@property (nonatomic,assign) id delegate;

- (id)initWithFeedSource:(CKFeedSource*)source;
- (id)initWithFeedSource:(CKFeedSource*)source withStorage:(id)storage;

- (NSInteger)count;
- (NSArray*)allObjects;
- (id)objectAtIndex:(NSInteger)index;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsInArray:(NSArray *)otherArray;
- (void)removeAllObjects;

- (BOOL)load;
- (BOOL)save;

- (void)addObserver:(id)object;
- (void)removeObserver:(id)object;
- (void)fetchRange:(NSRange)range;

@end

@protocol CKDocumentCollectionDelegate
- (void)documentCollectionDidLoad:(CKDocumentCollection*)collection;
- (void)documentCollectionDidSave:(CKDocumentCollection*)collection;
- (void)documentCollectionDidFailLoading:(CKDocumentCollection*)collection;
- (void)documentCollectionDidFailSaving:(CKDocumentCollection*)collection;
@end
