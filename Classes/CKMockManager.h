//
//  CKMockManager.h
//  CloudKit
//
//  Created by Martin Dufort on 12-06-07.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKCascadingTree.h"

/** TODO
 */
@interface CKMockManager : CKCascadingTree

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (CKMockManager*)defaultManager;

///-----------------------------------
/// @name Importing .mock files content
///-----------------------------------

/**
 */
- (void)loadContentOfFileNamed:(NSString*)name;

/**
 */
- (BOOL)importContentOfFileNamed:(NSString*)name;

@end
