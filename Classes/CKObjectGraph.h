//
//  CKObjectGraph.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCascadingTree.h"

/**
 */
@interface CKObjectGraph : CKCascadingTree

///-----------------------------------
/// @name Creating object graph objects
///-----------------------------------

/**
 */
+ (CKObjectGraph*)objectGraphWithContentOfFileNamed:(NSString*)name;

///-----------------------------------
/// @name Querying object graph
///-----------------------------------

/**
 */
- (id)objectWithUniqueId:(NSString*)uniqueId;

@end
