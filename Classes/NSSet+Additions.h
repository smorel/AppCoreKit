//
//  NSSet+Additions.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSSet (CKNSSetAdditions)

///-----------------------------------
/// @name Accessing Set Members
///-----------------------------------

/** Returns true is an object of the array validate the given predicate
 */
- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate;

@end