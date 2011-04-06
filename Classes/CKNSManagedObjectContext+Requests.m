//
//  CKNSManagedObjectContext+Requests.m
//
//  Created by Fred Brunel on 2010/01/05.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKNSManagedObjectContext+Requests.h"
#import "CKNSStringAdditions.h"
#import "CKDebug.h"

//

@implementation NSManagedObjectContext (CKNSManagedObjectContextRequestsAdditions)

- (NSFetchRequest *)fetchRequestWithEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate {
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
	[request setEntity:entity];
	
	if (predicate) { 
		[request setPredicate:predicate]; 
	}
	
	return request;
}

// Additions

- (id)insertNewObjectForEntityForName:(NSString *)entityName {
	id object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
	
	// FIXME
	if ([object respondsToSelector:@selector(setCreatedAt:)]) { [object setCreatedAt:[NSDate date]]; }
	
	return object;
}

- (NSArray *)fetchObjectsForEntityForName:(NSString *)entityName 
								predicate:(NSPredicate *)predicate 
							 sortedByKeys:(NSArray *)sortKeys
									limit:(NSUInteger)limit {
	NSFetchRequest *request = [self fetchRequestWithEntityForName:entityName predicate:predicate];
	
	// Set the sort description
	if (sortKeys) {
		NSMutableArray *sortDescriptors = [NSMutableArray array];
		
		for (NSString *key in sortKeys) {
			[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:key ascending:YES] autorelease]];
		}
		
		[request setSortDescriptors:sortDescriptors];
	}
	
	// Set the limits
	if (limit != 0) {
		[request setFetchLimit:limit];
	}
	
	// Set batch size
	[request setFetchBatchSize:20];
	
	NSError *error = nil;
	NSArray *fetchResults = [self executeFetchRequest:request error:&error];
	
	if (error) {
		// FIXME: Send the error back to the client with via a parameter (NSError **)error
		CKDebugLog(@"Error [%@] while fetching objects for [%@]", error, predicate);
		return [NSArray array];
	}
	
//	CKDebugLog(@"Success fetching %d result(s) for [%@]", fetchResults.count, predicate);
	
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
	NSFetchRequest *request = [self fetchRequestWithEntityForName:entityName predicate:predicate];	
	NSError *error = nil;
	NSUInteger count = [self countForFetchRequest:request error:&error];
	
	if (error) {
		// FIXME: Send the error back to the client with via a parameter (NSError **)error
		CKDebugLog(@"Error [%@] while fetching objects for [%@]", error, predicate);
		return 0;
	}
	
	return count;
}

//

- (id)fetchObjectForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate createIfNotFound:(BOOL)createIfNotFound wasCreated:(BOOL *)wasCreated {
	NSArray *fetchResults = [self fetchObjectsForEntityForName:entityName predicate:predicate sortedBy:nil limit:0];	
	BOOL created = NO;
	id object = nil;
	
	if ((fetchResults.count == 0) && createIfNotFound) {
		created = YES;
		object =  [self insertNewObjectForEntityForName:entityName]; 
	} else if (fetchResults.count == 1) { 
		created = NO;
		object = [fetchResults objectAtIndex:0]; 
	} else {
		NSAssert3(fetchResults.count > 1, @"Expected 1 object of type %@ but got %d [%@]", entityName, fetchResults.count, predicate);
	}
	
	if (wasCreated) { *wasCreated = created; }
	return object;
}

- (id)fetchFirstObjectForEntityForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortedBy:(NSString *)sortKey {
	NSArray *results = [self fetchObjectsForEntityForName:entityName predicate:predicate sortedBy:sortKey limit:0];
	return (results.count == 0) ? nil : [results objectAtIndex:0];
}

//

- (void)deleteObjects:(NSArray *)objects {
	for (NSManagedObject *object in objects) { [self deleteObject:object]; }
}

@end
