//
//  CKNSArrayAdditions.h
//
//  Created by Fred Brunel on 05/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CKNSArrayAdditions)

// Returns the first element of the array
- (id)first;

// Returns the second element of the array
- (id)second;

// Returns the last element of the array
- (id)last;

// Returns a possibly empty array of the items after the first
- (NSArray *)rest;

// Returns a copy of the array with elements in reverse order 
- (NSArray *)reversedArray;

// Returns true is a string of the array is contains another given string
- (BOOL)containsString:(NSString *)string;

// Returns true is an object of the array validate the given predicate
- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate;

// Returns a new array with the result of applying the given selector to each element of the array
- (NSArray *)arrayByApplyingSelector:(SEL)selector;

@end

//

@interface NSSet (CKNSSetAdditions)

// Returns true is an object of the array validate the given predicate
- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate;

@end
