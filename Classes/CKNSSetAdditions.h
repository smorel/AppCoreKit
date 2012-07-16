//
//  CKNSSetAdditions.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSSet (CKNSSetAdditions)

// Returns true is an object of the array validate the given predicate
- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate;

@end