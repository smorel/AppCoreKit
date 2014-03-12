//
//  NSArray+Compare.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/10/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Compare)

- (void)compareToArray:(NSArray*)other addedIndexSet:(NSMutableIndexSet**)addedIndexSet removedIndexSet:(NSMutableIndexSet**)removedIndexSet;

@end
