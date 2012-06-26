//
//  CKSuffixTree+Generator.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-04.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKSuffixTree.h"

/**
 */
@interface CKSuffixTree(CKSuffixTreeGenerator)

///-----------------------------------
/// @name Generating suffix tree files from a sorted text file
///-----------------------------------

/**
 */
+ (void)generateSuffixTreeWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path maximumNumberOfObjectsPerIndex:(NSUInteger)indexLimit;

/**
 */
+ (void)generateSuffixTreeWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path;

@end
