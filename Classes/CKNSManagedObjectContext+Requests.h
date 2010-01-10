//
//  CKNSManagedObjectContext+Request.h
//
//  Created by Fred Brunel on 2010/01/05.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (CKNSManagedObjectPropertiesAdditions)

- (void)setIdentifier:(NSString *)identifier;
- (void)setCreatedAt:(NSDate *)date;
- (void)setUpdatedAt:(NSDate *)date;

@end

//

@interface NSManagedObjectContext (CKNSManagedObjectContextRequestsAdditions)

- (id)insertNewObjectForEntityForName:(NSString *)entityName;

- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)key limit:(NSUInteger)limit;
- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedByKeys:(NSArray *)keys limit:(NSUInteger)limit;
- (NSUInteger)countObjectsForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate;

- (id)fetchObjectForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate createIfNotFound:(BOOL)createIfNotFound wasCreated:(BOOL *)wasCreated;
- (id)fetchFirstObjectForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)sortKey;

@end
