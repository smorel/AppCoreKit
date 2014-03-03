//
//  CKStyleManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCascadingTree.h"

extern NSString* CKStyleManagerDidReloadNotification;

/**
 */
@interface CKStyleManager : CKCascadingTree 

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (CKStyleManager*)defaultManager;

/** This returns a style manager initialized with the content of the specified file name.
    This stylemanager is store in a cache so that the next time we query a stylemanager with the same file name, an existing instance is returned.
    The cache version of this stylemanager is released when all the stylemanager instances for the specified file named are released.
 */
+ (CKStyleManager*)styleManagerWithContentOfFileNamed:(NSString*)fileName;

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

/** PRIVATE : When viewControllers or cell controller apply style, they keep a track of the resource paths they are dependent
    By this way, the stylemanager can register for updates on those dependencies and reload correctly when the resources gets updated.
 */
- (void)registerOnDependencies:(NSSet*)dependencies;

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