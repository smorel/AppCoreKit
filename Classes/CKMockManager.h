//
//  CKMockManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKCascadingTree.h"

/**
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
