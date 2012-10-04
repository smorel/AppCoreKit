//
//  CKCollection.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"
#import "CKFeedSource.h"

typedef void(^CKCollectionBlock)(NSArray* objects,NSIndexSet* indexes);
typedef void(^CKCollectionReplaceBlock)(id object,id replacedObject,NSInteger index);
typedef void(^CKCollectionClearBlock)();
typedef void(^CKCollectionFetchBlock)(NSRange range);

//TODO :  Implements fast enumeration protocol

/** :
 */
@interface CKCollection : NSObject<NSCopying,NSMutableCopying,CKFeedSourceDelegate,NSFastEnumeration>

///-----------------------------------
/// @name Creating collection objects
///-----------------------------------

/**
 */
+ (id)collection;

/**
 */
+ (id)collectionWithFeedSource:(CKFeedSource*)source;

/**
 */
+ (id)collectionWithObjectsFromArray:(NSArray*)array;

///-----------------------------------
/// @name Initializing collection objects
///-----------------------------------

/**
 */
- (id)initWithFeedSource:(CKFeedSource*)source;

/**
 */
- (id)initWithObjectsFromArray:(NSArray*)array;

/** Overload this method to initialize your objects property whatever initializer is called. Do not forget to call the super implementation first.
 */
- (void)postInit;


///-----------------------------------
/// @name Accessing the feed source
///-----------------------------------

/**
 */
@property (nonatomic,retain) CKFeedSource* feedSource;

/**
 */
@property (nonatomic,assign,readonly) BOOL isFetching;


///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property (nonatomic,assign) id delegate;

/**
 */
@property (nonatomic,copy) CKCollectionBlock addObjectsBlock;

/**
 */
@property (nonatomic,copy) CKCollectionBlock removeObjectsBlock;

/**
 */
@property (nonatomic,copy) CKCollectionReplaceBlock replaceObjectBlock;

/**
 */
@property (nonatomic,copy) CKCollectionClearBlock clearBlock;

/**
 */
@property (nonatomic,copy) CKCollectionFetchBlock startFetchingBlock;

/**
 */
@property (nonatomic,copy) CKCollectionBlock endFetchingBlock;


///-----------------------------------
/// @name Querying the collection
///-----------------------------------

/**
 */
@property (nonatomic,assign,readonly) NSInteger count;

/**
 */
- (NSArray*)allObjects;

/**
 */
- (BOOL)containsObject:(id)object;

/**
 */
- (id)objectAtIndex:(NSInteger)index;

/**
 */
- (NSArray*)objectsMatchingPredicate:(NSPredicate*)predicate;

///-----------------------------------
/// @name Adding Objects
///-----------------------------------

/**
 */
- (void)addObject:(id)object;

/**
 */
- (void)addObjectsFromArray:(NSArray *)otherArray;

/**
 */
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;

///-----------------------------------
/// @name Removing Objects
///-----------------------------------

/**
 */
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet;

/**
 */
- (void)removeAllObjects;

///-----------------------------------
/// @name Replacing Objects
///-----------------------------------

/**
 */
- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other;

///-----------------------------------
/// @name Managing observers
///-----------------------------------

/**
 */
- (void)addObserver:(id)object;

/**
 */
- (void)removeObserver:(id)object;

///-----------------------------------
/// @name Fetching the collection
///-----------------------------------

/**
 */
- (void)fetchRange:(NSRange)range;

/**
 */
- (void)cancelFetch;

@end


/**
 */
@protocol CKCollectionDelegate
@optional
///-----------------------------------
/// @name Reacting to collection events
///-----------------------------------

/**
 */
- (void)documentCollection:(CKCollection *)collection didFetchItems:(NSArray *)items atRange:(NSRange)range;

/**
 */
- (void)documentCollection:(CKCollection *)collection fetchDidFailWithError:(NSError *)error;

/**
 */
- (void)documentCollectionDidChange:(CKCollection*)collection;

@end
