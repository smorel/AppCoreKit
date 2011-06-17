//
//  CKStore.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <stdarg.h>

#import "CKStore.h"
#import "CKCoreDataManager.h"

#import "CKDomain.h"
#import "CKItem.h"
#import "CKAttribute.h"

#import "CKNSStringAdditions.h"

@interface CKStore ()

@property (retain, readwrite) CKCoreDataManager *manager;
@property (retain, readwrite) CKDomain *domain;

@end

@implementation CKStore

@synthesize manager = _manager;
@synthesize domain = _domain;

#pragma mark CKStore Initialization

+ (id)storeWithDomainName:(NSString *)domainName {
	return [[[CKStore alloc] initWithDomainName:domainName] autorelease];
}

- (id)initWithDomainName:(NSString *)domainName {
	if (self = [super init]) {
		// FIXME: There should be 1 specific CoreDataManager for the CKStore, 
		// separated from the CoreDataManager of the application.
		self.manager = [CKCoreDataManager sharedManager];
		
		// Fetch the domain, creating it if necessary
		BOOL created;
		self.domain = [self.manager.objectContext fetchObjectForEntityForName:@"CKDomain" 
																	predicate:[NSPredicate predicateWithFormat:@"name == %@", domainName] 
															 createIfNotFound:YES
																   wasCreated:&created];
		if (created) { 
			self.domain.name = domainName; 
		}
	}
	return self;
}

#pragma mark CKStore Fetch Items

- (NSArray *)fetchItems {
	return [self fetchItemsWithPredicateFormat:nil arguments:nil];
}

- (NSArray  *)fetchItemsWithLimit:(NSUInteger)limit {
	return [self fetchItemsWithPredicateFormat:nil arguments:nil limit:limit];
}

- (NSArray *)fetchItemsWithNames:(NSArray *)names {
	return (names ? [self fetchItemsWithPredicateFormat:@"(name IN %@)" arguments:[NSArray arrayWithObject:names]] : [self fetchItems]);	
}

- (NSArray *)fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments {
	return [self fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments limit:0];
}

// Generic Fetch

- (NSArray *)fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments limit:(NSUInteger)limit {	
	// Adds the "domain scope" for the predicate, equivalent to the format string
	// [NSPredicate predicateWithFormat:@"domain == %@ [...]", self.domain, [...]];

	/*NSMutableArray *predicateArguments = [NSMutableArray arrayWithObject:self.domain];
	[predicateArguments addObjectsFromArray:arguments];
		
	NSMutableString *scopedPredicateFormat = [NSMutableString stringWithString:@"(domain == %@)"];
	if (predicateFormat) { [scopedPredicateFormat appendFormat:@" AND (%@)", predicateFormat]; }
	NSPredicate *predicate = [NSPredicate predicateWithFormat:scopedPredicateFormat argumentArray:predicateArguments];
	
	return [self.manager.objectContext fetchObjectsForEntityForName:@"CKItem" predicate:predicate sortedBy:@"createdAt" limit:limit];*/
	return [self fetchItemsWithFormat:predicateFormat arguments:arguments range:NSMakeRange(0,limit) sortedByKeys:[NSArray arrayWithObject:@"createdAt"]];
}

- (NSArray *)fetchItemsWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments range:(NSRange)range sortedByKeys:(NSArray*)keys{
	// Adds the "domain scope" for the predicate, equivalent to the format string
	// [NSPredicate predicateWithFormat:@"domain == %@ [...]", self.domain, [...]];
	
	NSMutableArray *predicateArguments = [NSMutableArray arrayWithObject:self.domain];
	if(arguments != nil){
		[predicateArguments addObjectsFromArray:arguments];
	}
	
	NSMutableString *scopedPredicateFormat = [NSMutableString stringWithString:@"(domain == %@)"];
	if (predicateFormat) { [scopedPredicateFormat appendFormat:@" AND (%@)", predicateFormat]; }
	NSPredicate *predicate = [NSPredicate predicateWithFormat:scopedPredicateFormat argumentArray:predicateArguments];
	
	return [self.manager.objectContext fetchObjectsForEntityForName:@"CKItem" predicate:predicate sortedByKeys:keys range:range];
}

- (NSArray *)fetchAttributesWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments {
	return [self fetchAttributesWithFormat:predicateFormat arguments:arguments range:NSMakeRange(0,0) sortedByKeys:[NSArray arrayWithObject:@"createdAt"]];
}

- (NSArray *)fetchAttributesWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments range:(NSRange)range sortedByKeys:(NSArray*)keys{
	// Adds the "domain scope" for the predicate, equivalent to the format string
	// [NSPredicate predicateWithFormat:@"domain == %@ [...]", self.domain, [...]];
	
	NSMutableArray *predicateArguments = [NSMutableArray arrayWithObject:self.domain];
	if(arguments != nil){
		[predicateArguments addObjectsFromArray:arguments];
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:predicateArguments];
	return [self.manager.objectContext fetchObjectsForEntityForName:@"CKAttribute" predicate:predicate sortedByKeys:keys range:range];
}

#pragma mark CKStore Count Items

- (NSUInteger)countItems {
	return [self.manager.objectContext countObjectsForEntityForName:@"CKItem" 
														  predicate:[NSPredicate predicateWithFormat:@"(domain == %@)", self.domain]];
}

#pragma mark CKStore Delete Items

- (void)deleteItems:(NSArray *)items {
	[self.manager.objectContext deleteObjects:items];
}

- (void)deleteItemsWithNames:(NSArray *)names {
	[self deleteItems:[self fetchItemsWithNames:names]];
}

#pragma mark CKStore Insert Attributes

- (NSString *)insertAttributesWithValuesForNames:(NSDictionary *)attributes forItemNamed:(NSString *)itemName {
	BOOL created;
	
	// Generate an item name automatically, if not provided.
	
	NSString *name = itemName ? itemName : [NSString stringWithNewUUID];
	
	// Fetch the item
	
	CKItem *item = [self.manager.objectContext fetchObjectForEntityForName:@"CKItem" 
																 predicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (domain == %@)", name, self.domain]
														  createIfNotFound:YES
																wasCreated:&created];
	if (created) {
		item.name = name;
		item.domain = self.domain;
		[self.domain addItemsObject:item];
	}
	
	// Insert attributes
	[item updateAttributes:attributes];
	return name;
}

#pragma mark CKStore Fetch Attributes

- (NSArray *)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName {
	return [self fetchAttributesWithNames:names forItemNamed:itemName resultType:CKStoreAttributeResultType];
}

- (id)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName resultType:(CKStoreResultType)resultType {
	NSPredicate *predicate;
	
	if (names) {
		predicate = [NSPredicate predicateWithFormat:@"(name IN %@) AND (item.name == %@) AND (item.domain == %@)", names, itemName, self.domain];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"(item.name == %@) AND (item.domain == %@)", itemName, self.domain];
	}
		
	NSArray *attributes = [self.manager.objectContext fetchObjectsForEntityForName:@"CKAttribute" 
																		 predicate:predicate 
																	  sortedByKeys:nil 
																			 limit:0];
	
	if (resultType == CKStoreAttributeResultType) {
		return attributes;
	} else {
		return [[NSValueTransformer valueTransformerForName:@"CKDictionaryFromAttributesTransformer"] transformedValue:attributes];
	}
}


@end


@implementation CKStore (CKStorePrivateAddition)

- (CKAttribute*)fetchAttributeWithPredicate:(NSPredicate*)predicate createIfNotFound:(BOOL)createIfNotFound wasCreated:(BOOL*)wasCreated{
	return [self.manager.objectContext fetchObjectForEntityForName:@"CKAttribute"
														 predicate:predicate
												  createIfNotFound:createIfNotFound 
														wasCreated:wasCreated];
}

- (CKItem*)fetchItemWithPredicate:(NSPredicate*)predicate createIfNotFound:(BOOL)createIfNotFound wasCreated:(BOOL*)wasCreated{
	return [self.manager.objectContext fetchObjectForEntityForName:@"CKItem"
														 predicate:predicate
												  createIfNotFound:createIfNotFound 
														wasCreated:wasCreated];
}

- (id)insertNewObjectForEntityForName:(NSString *)entityName{
	return [self.manager.objectContext insertNewObjectForEntityForName:entityName];
}

@end