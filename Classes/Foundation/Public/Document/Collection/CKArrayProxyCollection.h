//
//  CKArrayProxyCollection.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollection.h"
#import "CKProperty.h"


/**
 */
@interface CKArrayProxyCollection : CKCollection 

///-----------------------------------
/// @name Creating an array proxy collection
///-----------------------------------

/**
 */
+ (CKArrayProxyCollection*)collectionWithArrayProperty:(CKProperty*)property;

///-----------------------------------
/// @name Initializing an array proxy collection
///-----------------------------------

/**
 */
- (id)initWithArrayProperty:(CKProperty*)property;

///-----------------------------------
/// @name Getting the array property
///-----------------------------------

/**
 */
@property (nonatomic,retain) CKProperty* property;


@end
