//
//  CKStyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCascadingTree.h"


/** TODO
 */
@interface CKStyleManager : CKCascadingTree 

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (CKStyleManager*)defaultManager;

///-----------------------------------
/// @name Importing .style files content
///-----------------------------------

/**
 */
- (void)loadContentOfFileNamed:(NSString*)name;

/**
 */
- (BOOL)importContentOfFileNamed:(NSString*)name;

///-----------------------------------
/// @name Querying Style
///-----------------------------------

/**
 */
- (NSMutableDictionary*)styleForObject:(id)object  propertyName:(NSString*)propertyName;

///-----------------------------------
/// @name Accessing Debug Attributes
///-----------------------------------

/**
 */
+ (BOOL)logEnabled;

@end


/** TODO
 */
@interface NSMutableDictionary (CKStyleManager)

///-----------------------------------
/// @name Querying Style
///-----------------------------------

/**
 */
- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName;

@end