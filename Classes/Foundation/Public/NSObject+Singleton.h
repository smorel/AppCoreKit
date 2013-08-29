//
//  NSObject+CKSingleton.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSObject (CKSingleton)

///-----------------------------------
/// @name Singleton
///-----------------------------------

/** You can overload this method to customize how the shared instance will get created
 */
+ (id)newSharedInstance;

/**
 */
+ (id)sharedInstance;

/**
 */
+ (void)setSharedInstance:(id)instance;

@end
