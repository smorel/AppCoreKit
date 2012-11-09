//
//  CKStyleManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCascadingTree.h"


/**
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
- (BOOL)isEmpty;

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


/**
 */
@interface NSMutableDictionary (CKStyleManager)

///-----------------------------------
/// @name Querying Style
///-----------------------------------

/**
 */
- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName;

@end


@interface NSObject (CKStyleManager)

- (NSMutableDictionary*)stylesheet;
- (void)findAndApplyStyleFromStylesheet:(NSMutableDictionary*)parentStylesheet propertyName:(NSString*)propertyName;

@end