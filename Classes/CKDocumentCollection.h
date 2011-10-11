//
//  CKDocumentCollection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"
#import "CKFeedSource.h"
#import "CKDocumentStorage.h"

typedef void(^CKDocumentCollectionBlock)(NSArray* objects,NSIndexSet* indexes);
typedef void(^CKDocumentCollectionReplaceBlock)(id object,id replacedObject,NSInteger index);
typedef void(^CKDocumentCollectionClearBlock)();
typedef void(^CKDocumentCollectionFetchBlock)(NSRange range);

/** TODO : Implements fast enumeration protocol
 */
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

@property (nonatomic,copy) CKDocumentCollectionBlock addObjectsBlock;
@property (nonatomic,copy) CKDocumentCollectionBlock removeObjectsBlock;
@property (nonatomic,copy) CKDocumentCollectionReplaceBlock replaceObjectBlock;
@property (nonatomic,copy) CKDocumentCollectionClearBlock clearBlock;
@property (nonatomic,copy) CKDocumentCollectionFetchBlock startFetchingBlock;
@property (nonatomic,copy) CKDocumentCollectionBlock endFetchingBlock;

- (id)initWithFeedSource:(CKFeedSource*)source;
- (id)initWithFeedSource:(CKFeedSource*)source withStorage:(id)storage;
- (id)initWithStorage:(id)storage;

- (NSArray*)allObjects;
- (BOOL)containsObject:(id)object;
- (id)objectAtIndex:(NSInteger)index;
- (void)addObject:(id)object;
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


/** TODO
 */
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
