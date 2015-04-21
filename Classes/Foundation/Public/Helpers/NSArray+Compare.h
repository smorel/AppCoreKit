//
//  NSArray+Compare.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/10/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Compare)

/** commonIndexSet and removedIndexSet: indexes in self
    addedIndexSet: indexes in other
 */
- (void)compareToArray:(NSArray*)other commonIndexSet:(NSMutableIndexSet**)commonIndexSet addedIndexSet:(NSMutableIndexSet**)addedIndexSet removedIndexSet:(NSMutableIndexSet**)removedIndexSet;
- (void)compareToArray:(NSArray*)other commonIndexSet:(NSMutableIndexSet**)commonIndexSet addedIndexSet:(NSMutableIndexSet**)addedIndexSet removedIndexSet:(NSMutableIndexSet**)removedIndexSet identicalTo:(BOOL)identicalTo;

@end
