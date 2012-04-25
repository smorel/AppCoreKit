//
//  CKCollection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"
#import "CKFeedSource.h"

typedef void(^CKCollectionBlock)(NSArray* objects,NSIndexSet* indexes);
typedef void(^CKCollectionReplaceBlock)(id object,id replacedObject,NSInteger index);
typedef void(^CKCollectionClearBlock)();
typedef void(^CKCollectionFetchBlock)(NSRange range);

/** TODO : Implements fast enumeration protocol
 */
@interface CKCollection : NSObject<NSCopying,CKFeedSourceDelegate> {
	CKFeedSource* _feedSource;
	id _delegate;
	NSInteger _count;
}

@property (nonatomic,retain) CKFeedSource* feedSource;
@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) NSInteger count;

@property (nonatomic,copy) CKCollectionBlock addObjectsBlock;
@property (nonatomic,copy) CKCollectionBlock removeObjectsBlock;
@property (nonatomic,copy) CKCollectionReplaceBlock replaceObjectBlock;
@property (nonatomic,copy) CKCollectionClearBlock clearBlock;
@property (nonatomic,copy) CKCollectionFetchBlock startFetchingBlock;
@property (nonatomic,copy) CKCollectionBlock endFetchingBlock;

+ (id)object;

- (id)initWithFeedSource:(CKFeedSource*)source;

- (NSArray*)allObjects;
- (BOOL)containsObject:(id)object;
- (id)objectAtIndex:(NSInteger)index;
- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet;
- (void)removeAllObjects;
- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other;

- (void)addObserver:(id)object;
- (void)removeObserver:(id)object;
- (void)fetchRange:(NSRange)range;

- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate;

//private
- (void)postInit;

@end


/** TODO
 */
@protocol CKCollectionDelegate
@optional
- (void)documentCollection:(CKCollection *)collection didFetchItems:(NSArray *)items atRange:(NSRange)range;
- (void)documentCollection:(CKCollection *)collection fetchDidFailWithError:(NSError *)error;
- (void)documentCollectionDidChange:(CKCollection*)collection;
@end
