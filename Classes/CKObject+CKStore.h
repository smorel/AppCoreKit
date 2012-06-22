//
//  CKNSObject+CKStore.h
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"


/** TODO
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