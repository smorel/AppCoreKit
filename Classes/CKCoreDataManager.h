//
//  CKCoreDataManager.h
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CKNSManagedObjectContext+Requests.h"

/** TODO
 */
@interface CKCoreDataManager : NSObject {
	NSURL *_storeURL;
    NSURL *_modelURL;
	NSString *_storeType;
	NSDictionary *_storeOptions;
    NSManagedObjectModel *_objectModel;
    NSManagedObjectContext *_objectContext;	    
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;	
}

@property (retain, readonly) NSURL *storeURL;
@property (retain, readonly) NSURL *modelURL;
@property (retain, readonly) NSString *storeType;
@property (retain, readonly) NSDictionary *storeOptions;

@property (retain, readonly) NSManagedObjectModel *objectModel;
@property (retain, readonly) NSManagedObjectContext *objectContext;
@property (retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//

- (CKCoreDataManager *)initWithModelURL:(NSURL *)modelURL;
- (CKCoreDataManager *)initWithPersistentStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL storeType:(NSString *)storeType storeOptions:(NSDictionary *)storeOptions;
- (void)save;

@end
