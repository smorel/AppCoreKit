//
//  CKCoreDataManager.h
//
//  Created by Fred Brunel on 2010/01/05.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CKNSManagedObjectContext+Requests.h"

@interface CKCoreDataManager : NSObject {
	NSURL *_storeURL;
	NSString *_storeType;
	NSDictionary *_storeOptions;
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;	    
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;	
}

@property (retain, readonly) NSURL *storeURL;
@property (retain, readonly) NSString *storeType;
@property (retain, readonly) NSDictionary *storeOptions;

@property (retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CKCoreDataManager *)sharedManager;
+ (void)setSharedManager:(CKCoreDataManager *)manager;

//

- (CKCoreDataManager *)initWithDefault;
- (CKCoreDataManager *)initWithPersistentStoreURL:(NSURL *)storeURL storeType:(NSString *)storeType storeOptions:(NSDictionary *)storeOptions;

- (void)save;

@end
