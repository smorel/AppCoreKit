//
//  CKObject+CKSingleton.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-13.
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

@end
