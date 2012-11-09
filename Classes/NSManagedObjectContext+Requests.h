//
//  NSManagedObjectContext+Request.h
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 */
@interface NSManagedObject (CKNSManagedObjectPropertiesAdditions)

///-----------------------------------
/// @name Accessing ManagedObject attributes
///-----------------------------------

/**
 */
- (void)setIdentifier:(NSString *)identifier;

/**
 */
- (void)setCreatedAt:(NSDate *)date;

/**
 */
- (void)setUpdatedAt:(NSDate *)date;

@end

//

/**
 */
@interface NSManagedObjectContext (CKNSManagedObjectContextRequestsAdditions)

///-----------------------------------
/// @name Inserting entities in managed object context
///-----------------------------------

/**
 */
- (id)insertNewObjectForEntityForName:(NSString *)entityName;

///-----------------------------------
/// @name Removing entities from managed object context
///-----------------------------------

/**
 */
- (void)removeObjects:(NSArray *)objects;

///-----------------------------------
/// @name Querying Managed Object Context
///-----------------------------------

/**
 */
- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)key range:(NSRange)range;

/**
 */
- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedByKeys:(NSArray *)keys range:(NSRange)range;

/**
 */
- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)key limit:(NSUInteger)limit;

/**
 */
- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedByKeys:(NSArray *)keys limit:(NSUInteger)limit;

/**
 */
- (NSUInteger)countObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate;

/**
 */
- (id)fetchObjectForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate createIfNotFound:(BOOL)createIfNotFound wasCreated:(BOOL *)wasCreated;

/**
 */
- (id)fetchFirstObjectForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)sortKey;


@end
