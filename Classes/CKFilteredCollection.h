//
//  CKFilteredCollection.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKArrayCollection.h"

/**
 */
@interface CKFilteredCollection : CKArrayCollection

///-----------------------------------
/// @name Creating filtered collection objects
///-----------------------------------

/**
 */
+ (CKFilteredCollection*)filteredCollectionWithCollection:(CKCollection*)collection usingPredicate:(NSPredicate*)predicate;

///-----------------------------------
/// @name Initializing filtered collection objects
///-----------------------------------

/**
 */
- (id)initWithCollection:(CKCollection*)collection usingPredicate:(NSPredicate*)predicate;

///-----------------------------------
/// @name Setuping a filtered collection at runtime
///-----------------------------------

/**
 */
@property(nonatomic,retain)CKCollection* collection;

/**
 */
@property(nonatomic,retain)NSPredicate* predicate;

@end
