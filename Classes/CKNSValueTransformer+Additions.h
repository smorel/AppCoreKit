//
//  CKSerializer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKProperty.h"
#import "CKArrayCollection.h"

/**
 */
@interface NSValueTransformer (CKAddition)

///-----------------------------------
/// @name Transforming values
///-----------------------------------

/**
 */
+ (id)transform:(id)object inProperty:(CKProperty*)property;

/**
 */
+ (id)transform:(id)source toClass:(Class)type;

/**
 */
+ (id)transformProperty:(CKProperty*)property toClass:(Class)type;

/**
 */
+ (void)transform:(NSDictionary*)source toObject:(id)target;

@end
