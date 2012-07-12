//
//  CKAggregateCollection.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKArrayCollection.h"

/**
 */
@interface CKAggregateCollection : CKArrayCollection

///-----------------------------------
/// @name Initializing aggregate collection objects
///-----------------------------------

/**
 */
+ (CKAggregateCollection*)aggregateCollectionWithCollections:(NSArray*)collections;

///-----------------------------------
/// @name Initializing aggregate collection objects
///-----------------------------------

/**
 */
- (id)initWithCollections:(NSArray*)collections;

///-----------------------------------
/// @name Setuping an aggregate collection at runtime
///-----------------------------------

/**
 */
@property(nonatomic,retain)NSArray* collections;

@end
