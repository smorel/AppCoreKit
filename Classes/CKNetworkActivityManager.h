//
//  CKNetworkActivityManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 */
@interface CKNetworkActivityManager : NSObject {
	NSMutableSet *_objects;
}

///-----------------------------------
/// @name Singleton
///-----------------------------------

/** 
 */
+ (CKNetworkActivityManager*)defaultManager;

///-----------------------------------
/// @name Managing Activity Indicator
///-----------------------------------

/** 
 */
- (void)addNetworkActivityForObject:(id)object;
- (void)removeNetworkActivityForObject:(id)object;

@end
