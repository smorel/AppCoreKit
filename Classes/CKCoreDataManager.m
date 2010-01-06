//
//  CKCoreDataManager.h
//
//  Created by Fred Brunel on 2010/01/05.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCoreDataManager.h"
#import "CKNSDateAdditions.h"
#import "CKNSStringAdditions.h"
#import "CKDebug.h"

// Private Interface

@interface CKCoreDataManager (Private)

@property (retain, readwrite) NSURL *storeURL;
@property (retain, readwrite) NSString *storeType;
@property (retain, readwrite) NSDictionary *storeOptions;

- (NSString *)_applicationDocumentsDirectory;
- (NSURL *)_storeURLForName:(NSString *)name storeType:(NSString *)storeType;

@end

// Implementation

@implementation CKCoreDataManager

@synthesize storeURL = _storeURL;
@synthesize storeType = _storeType;
@synthesize storeOptions = _storeOptions;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//

+ (CKCoreDataManager *)sharedManager {
	static CKCoreDataManager *_instance = nil;
	@synchronized(self) {
		if (! _instance) {
			_instance = [[CKCoreDataManager alloc] init];
		}
	}
	return _instance;
}

//

- (CKCoreDataManager *)init {
	NSURL *storeURL = [self _storeURLForName:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey] storeType:NSSQLiteStoreType];
	NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:
								    [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
								    [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	return [self initWithPersistentStoreURL:storeURL storeType:NSSQLiteStoreType storeOptions:storeOptions];
}

- (CKCoreDataManager *)initWithPersistentStoreURL:(NSURL *)storeURL storeType:(NSString *)storeType storeOptions:(NSDictionary *)storeOptions {
	if (self = [super init]) {
		self.storeURL = storeURL;
		self.storeType = storeType;
		self.storeOptions = storeOptions;
	}
	return self;
}

- (void)dealloc {	
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];    
	[super dealloc];
}

// // NSManagedObjectContext Additions

- (id)findOrCreateObjectForEntityForName:(NSString *)entityName withIdentifier:(NSString *)identifier {
	NSPredicate *predicate = identifier
		? [NSPredicate predicateWithFormat:@"identifier == %@", identifier]
		: nil;
	
	id entity = [self findFirstObjectForEntityForName:entityName 
											predicate:predicate 
											 sortedBy:nil];
		
	if (entity == nil) {
		entity = [self insertNewObjectForEntityForName:entityName];
		//[entity setCreatedAt:[NSDate date]];
		//[entity setUpdatedAt:[NSDate date]];
	} else {
		//[entity setUpdatedAt:[NSDate date]];
	}
	
	if (identifier) { [entity setIdentifier:identifier]; }

	return entity;
}

- (id)findFirstObjectForEntityForName:(NSString *)entityName 
							predicate:(NSPredicate *)predicate 
							 sortedBy:(NSString *)sortKey {
	
	NSArray *results = [self fetchObjectsForEntityForName:entityName 
												predicate:predicate 
												 sortedBy:sortKey 
													limit:0];
	return (results.count == 0) ? nil : [results objectAtIndex:0];
}

- (id)insertNewObjectForEntityForName:(NSString *)entityName {
	return [NSEntityDescription insertNewObjectForEntityForName:entityName
										 inManagedObjectContext:self.managedObjectContext];
}

- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName 
								predicate:(NSPredicate *)predicate 
							 sortedByKeys:(NSArray *)sortKeys
									limit:(NSUInteger)limit {
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	// Set the entity name
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	// Set the predicate
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	// Set the sort description
	if (sortKeys) {
		NSMutableArray *sortDescriptors = [NSMutableArray array];
		
		for (NSString *key in sortKeys) {
			[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:key ascending:YES] autorelease]];
		}
		
		[request setSortDescriptors:sortDescriptors];
	}
	
	// Set the limites
	if (limit != 0) {
		[request setFetchLimit:limit];
	}
	
	NSError *error;
	NSMutableArray *fetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (fetchResults == nil) {
		// FIXME: Handle the error.
	}
	
	CKDebugLog(@"%d result(s) [%@]", fetchResults.count, predicate);
	
	return fetchResults;
}

- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName 
								predicate:(NSPredicate *)predicate 
								 sortedBy:(NSString *)sortKey
									limit:(NSUInteger)limit {
	return [self fetchObjectsForEntityForName:entityName 
									predicate:predicate 
								 sortedByKeys:(sortKey == nil) ? nil : [NSArray arrayWithObject:sortKey]
										limit:limit];
}

- (NSUInteger)countObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate {
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	// Set the entity name
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	// Set the predicate
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	NSError *error = nil;
	NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
	if (error) {
		// FIXME: Handle the error.
	}

	return count;
}

- (void)deleteObject:(NSManagedObject *)object {
	if (_managedObjectContext != nil) { [_managedObjectContext deleteObject:object]; }
}

- (void)deleteObjects:(NSArray *)objects {
	for (id object in objects) { [self deleteObject:object]; }
}

// Saves changes in the application's managed object context

- (BOOL)save:(NSError **)error {
	if ([self.managedObjectContext hasChanges]) {
		return [self.managedObjectContext save:error]; 
	} else {
		return YES;
	}
}

- (void)save {	
    NSError *error;
	BOOL result = [self save:&error];
	NSAssert2(result, @"Unresolved error %@, %@", error, error.userInfo);
}

// Returns the managed object context.
// If the context doesn't already exist, it is created and bound to the 
// persistent store coordinator.

- (NSManagedObjectContext *)managedObjectContext {	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
	
    return _managedObjectContext;
}


// Returns the managed object model.
// If the model doesn't already exist, it is created by merging all of the 
// models found in the application bundle.

- (NSManagedObjectModel *)managedObjectModel {	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return _managedObjectModel;
}

// Returns the persistent store coordinator.
// If the coordinator doesn't already exist, it is created and the 
// application's store added to it.

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
	NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:self.storeType 
																		 configuration:nil 
																				   URL:self.storeURL
																			   options:self.storeOptions
																				 error:&error];
	NSAssert2(store, @"Unresolved error %@, %@", error, error.userInfo);
	
    return _persistentStoreCoordinator;
}

// Returns the path to the application's documents directory.

- (NSString *)_applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSURL *)_storeURLForName:(NSString *)name storeType:(NSString *)storeType {
	NSString *extension;
	
	if ([storeType isEqualToString:NSSQLiteStoreType]) {
		extension = @"sqlite";
	} else if ([storeType isEqualToString:NSBinaryStoreType]) {
		extension = @"db";
	} else {
		NSAssert1(NO, @"Unsupported store type %@", storeType);
	}
	
	return [NSURL fileURLWithPath:[[self _applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, extension]]];
}

@end
