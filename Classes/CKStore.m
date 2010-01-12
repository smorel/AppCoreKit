//
//  CKStore.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKStore.h"
#import "CKCoreDataManager.h"

#import "CKDomain.h"
#import "CKItem.h"
#import "CKAttribute.h"

@interface CKStore ()

@property (retain, readwrite) CKCoreDataManager *manager;
@property (retain, readwrite) CKDomain *domain;

@end

@implementation CKStore

@synthesize manager = _manager;
@synthesize domain = _domain;

//

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

// Items

- (NSArray *)fetchItemsUsingPredicate:(NSPredicate *)predicate {
	return [self.manager.objectContext fetchObjectsForEntityForName:@"CKItem" predicate:predicate sortedBy:@"createdAt" limit:0];
}

- (NSArray *)fetchItemsWithNames:(NSArray *)names {
	return [self fetchItemsUsingPredicate:[NSPredicate predicateWithFormat:@"name IN %@", names]];
}

- (void)deleteItemsWithNames:(NSArray *)names {
	[self.manager.objectContext deleteObjects:[self fetchItemsWithNames:names]];
}

// Attributes

- (void)insertAttributesWithValuesForNames:(NSDictionary *)attributes forItemNamed:(NSString *)itemName {
	BOOL created;
	
	CKItem *item = [self.manager.objectContext fetchObjectForEntityForName:@"CKItem" 
																 predicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (domain == %@)", itemName, self.domain]
														  createIfNotFound:YES
																wasCreated:&created];
	if (created) {
		item.name = itemName;
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
}

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
	}
	
	// Create a NSDictionary from the list of attributes
	
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	for (CKAttribute *attribute in attributes) {
		id object = [result objectForKey:attribute.name];
		
		if (object && [object isKindOfClass:[NSArray class]]) {
			[(NSMutableArray *)object addObject:attribute.value];
		} else if (object) {
			[result setObject:[NSMutableArray arrayWithObjects:object, attribute.value, nil] forKey:attribute.name];
		} else {
			[result setObject:attribute.value forKey:attribute.name];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:result];
}

@end
