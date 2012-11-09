//
//  NSArray+Additions.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSArray (CKNSArrayAdditions)

///-----------------------------------
/// @name Querying an Array
///-----------------------------------

/** Returns the first element of the array
 */
- (id)first;

/** Returns the second element of the array
 */
- (id)second;

/** Returns the last element of the array
 */
- (id)last;

/** Returns a possibly empty array of the items after the first
 */
- (NSArray *)rest;

/** Returns true if an object of the array validate the given predicate
 */
- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate;

///-----------------------------------
/// @name Sorting
///-----------------------------------

/** Returns a copy of the array with elements in reverse order 
 */
- (NSArray *)reversedArray;

/** Returns a copy of the array with elements in random order
 */
- (NSArray *)shuffledArray;

/** Returns true if the array contains a given string
 */
- (BOOL)containsString:(NSString *)string;

///-----------------------------------
/// @name Filtering
///-----------------------------------

/** Returns an array containing the return values from applying a given selector to each element of the receiver
 */
- (NSArray *)arrayWithValuesByMakingObjectsPerformSelector:(SEL)selector withObject:(id)object;

@end