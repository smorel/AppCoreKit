//
//  CKStore.h
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

// The CKStore is a simple key/value store with a model similar to Amazon SimpleDB.
//
// Usage:
//
// (1) Insert an item and its attributes (key/value pairs)
//
// [store insertAttributesWithValuesForNames:[NSDictionary dictionaryWithObjectsAndKeys:@"square", @"shape", @"green", @"color", nil] forItemNamed:@"object1"];
// NSDictionary *res1 = [store fetchAttributesWithNames:nil forItemNamed:@"object1" resultType:CKStoreNSDictionaryResultType];
//
// (2) Insert a multi-values on an attribute
//
// [store insertAttributesWithValuesForNames:[NSDictionary dictionaryWithObjectsAndKeys:@"blue", @"color", nil] forItemNamed:@"object2"];
// NSDictionary *res2 = [store fetchAttributesWithNames:[NSArray arrayWithObject:@"color"] forItemNamed:@"object2" resultType:CKStoreNSDictionaryResultType];
//
// [store insertAttributesWithValuesForNames:[NSDictionary dictionaryWithObjectsAndKeys:@"yellow", @"color", nil] forItemNamed:@"object2"];
// NSArray *res3 = [store fetchAttributesWithNames:[NSArray arrayWithObject:@"color"] forItemNamed:@"object2" resultType:CKStoreNSDictionaryResultType];
//
// (3) Query for items by selecting values on attributes
//
// NSArray *res4 = [store fetchItemsUsingPredicate:[NSPredicate predicateWithFormat:@"(ANY attributes.name == 'color') AND (ANY attributes.value IN {'green', 'blue'})"]];
//
// (4) Delete items with names
//
// [store deleteItemsWithNames:[NSArray arrayWithObjects:@"object1", @"object2", @"object3", nil]];
//

#import <Foundation/Foundation.h>

typedef enum {
	CKStoreAttributeResultType = 0,
	CKStoreNSDictionaryResultType
} CKStoreResultType;

@class CKCoreDataManager;
@class CKDomain;

@interface CKStore : NSObject {
	CKCoreDataManager *_manager;
	CKDomain *_domain;
}

+ (id)storeWithDomainName:(NSString *)domainName;
- (id)initWithDomainName:(NSString *)domainName;

// Items

- (NSArray *)fetchItemsUsingPredicate:(NSPredicate *)predicate;
- (void)deleteItemsWithNames:(NSArray *)names;

// Attributes

- (void)insertAttributesWithValuesForNames:(NSDictionary *)attributes forItemNamed:(NSString *)itemName;
- (NSArray *)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName;
- (id)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName resultType:(CKStoreResultType)resultType;

@end
