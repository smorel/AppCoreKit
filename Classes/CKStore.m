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

	NSMutableArray *predicateArguments = [NSMutableArray arrayWithObject:self.domain];
	[predicateArguments addObjectsFromArray:arguments];
		
	NSMutableString *scopedPredicateFormat = [NSMutableString stringWithString:@"(domain == %@)"];
	if (predicateFormat) { [scopedPredicateFormat appendFormat:@" AND (%@)", predicateFormat]; }
	NSPredicate *predicate = [NSPredicate predicateWithFormat:scopedPredicateFormat argumentArray:predicateArguments];
	
	return [self.manager.objectContext fetchObjectsForEntityForName:@"CKItem" predicate:predicate sortedBy:@"createdAt" limit:limit];
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
	
	for (id key in [attributes allKeys]) {
		NSAssert([key isKindOfClass:[NSString class]], @"Attribute key must be of class NSString");
		id value = [attributes objectForKey:key];
		NSAssert([value isKindOfClass:[NSString class]], @"Attribute value must be of class NSString");
		
		BOOL created = NO;
		CKAttribute *attribute = [self.manager.objectContext fetchObjectForEntityForName:@"CKAttribute"
																			   predicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (value == %@) AND (item == %@)", key, value, item]
																		createIfNotFound:YES 
																			  wasCreated:&created];
		if (created) {
			attribute.name = key;
			attribute.value = value;		
			[item addAttributesObject:attribute];
		}
	}
	
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
