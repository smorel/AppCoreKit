//
//  CKSuffixTree.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//



#import <Foundation/Foundation.h>

/* if we want to scale up the quantity of words or improve loading performances of the FAT, 
 we should implement partitioning of the FAT like databases.
 split the fat for a, b, c, ... and store the index in the file for the subSerch for a (ab,ac,aa,ad).
 load subseraches when needed only. By this way we could add as much sub layers as we need to have good performances.
 */



/**
 */
@interface CKSuffixTree : NSObject

///-----------------------------------
/// @name Initializing suffix tree objects
///-----------------------------------

/**
 */
- (id)initWithName:(NSString*)fileName;

///-----------------------------------
/// @name Identifying suffix tree at runtime
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSString *name;

///-----------------------------------
/// @name Querying suffix tree
///-----------------------------------

/**
 */
- (NSArray*)stringsWithSuffix:(NSString*)suffix range:(NSRange)range;

/**
 */
- (NSArray*)stringsWithSuffix:(NSString*)suffix;

/**
 */
- (NSUInteger)countStringsWithSuffix:(NSString*)suffix;

@end
