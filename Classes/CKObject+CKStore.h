//
//  CKObject+CKStore.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"


/**
 */
@interface CKObject (CKStoreAddition)

///-----------------------------------
/// @name Serializing Object in CKStore
///-----------------------------------

/**
 */
- (void)saveObjectToDomainNamed:(NSString*)domain;

/**
 */
- (void)saveObjectToDomainNamed:(NSString*)domain recursive:(BOOL)recursive;

///-----------------------------------
/// @name Removing Object from CKStore
///-----------------------------------

/**
 */
- (void)removeObjectFromDomainNamed:(NSString*)domain;

///-----------------------------------
/// @name Querying Objects in CKStore
///-----------------------------------

/**
 */
+ (CKObject*)objectWithUniqueId:(NSString*)uniqueId;

/**
 */
+ (CKObject*)loadObjectWithUniqueId:(NSString*)uniqueId;

@end