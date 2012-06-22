//
//  CKCoreDataManager.h
//
//  Created by Fred Brunel on 2010/01/05.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CKNSManagedObjectContext+Requests.h"

/** TODO
 */
@interface CKCoreDataManager : NSObject 

///-----------------------------------
/// @name Initializing CoreDataManager Objects
///-----------------------------------

/**
 */
- (CKCoreDataManager *)initWithModelURL:(NSURL *)modelURL;

/**
 */
- (CKCoreDataManager *)initWithPersistentStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL storeType:(NSString *)storeType storeOptions:(NSDictionary *)storeOptions;

///-----------------------------------
/// @name Accessing CoreDataManager Attributes
///-----------------------------------

/**
 */
@property (retain, readonly) NSURL *storeURL;

/**
 */
@property (retain, readonly) NSURL *modelURL;

/**
 */
@property (retain, readonly) NSString *storeType;

/**
 */
@property (retain, readonly) NSDictionary *storeOptions;

/**
 */
@property (retain, readonly) NSManagedObjectModel *objectModel;

/**
 */
@property (retain, readonly) NSManagedObjectContext *objectContext;

/**
 */
@property (retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

///-----------------------------------
/// @name Saving content To CoreData
///-----------------------------------

/**
 */
- (void)save;

@end
