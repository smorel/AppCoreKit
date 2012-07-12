//
//  CKStore.h
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 */
typedef enum {
	CKStoreAttributeResultType = 0,
	CKStoreNSDictionaryResultType
} CKStoreResultType;

@class CKCoreDataManager;
@class CKDomain;


/** 
  The CKStore is a simple key/value store with a model similar to Amazon SimpleDB.
 
  Usage:
 
  (1) Instanciate a store on a domain (ie. database); the domain will be created if needed.
 
  CKStore *store = [CKStore storeWithDomainName:@"test"];
 
  (2) Insert an item and its attributes (key/value pairs)
 
  [store insertAttributesWithValuesForNames:[NSDictionary dictionaryWithObjectsAndKeys:@"square", @"shape", @"green", @"color", nil] forItemNamed:@"object1"];
  NSDictionary *res = [store fetchAttributesWithNames:nil forItemNamed:@"object1" resultType:CKStoreNSDictionaryResultType];
 
  (3) Insert a multi-values on an attribute
 
  [store insertAttributesWithValuesForNames:[NSDictionary dictionaryWithObjectsAndKeys:@"blue", @"color", nil] forItemNamed:@"object2"];
  NSDictionary *res = [store fetchAttributesWithNames:[NSArray arrayWithObject:@"color"] forItemNamed:@"object2" resultType:CKStoreNSDictionaryResultType];
 
  [store insertAttributesWithValuesForNames:[NSDictionary dictionaryWithObjectsAndKeys:@"yellow", @"color", nil] forItemNamed:@"object2"];
  NSArray *res = [store fetchAttributesWithNames:[NSArray arrayWithObject:@"color"] forItemNamed:@"object2" resultType:CKStoreNSDictionaryResultType];
 
  (4) Query for items by selecting values on attributes
 
  NSArray *res = [store fetchItemsWithPredicateFormat:@"(ANY attributes.name == 'color') AND (ANY attributes.value IN {'green', 'blue'})" arguments:nil];
 
  (5) Delete items with names
 
  [store removeItemsWithNames:[NSArray arrayWithObjects:@"object1", @"object2", @"object3", nil]];
 
*/
@interface CKStore : NSObject 

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (CKCoreDataManager *)storeCoreDataManager;


///-----------------------------------
/// @name Creating initialized CKStore objects
///-----------------------------------

/**
 */
+ (id)storeWithDomainName:(NSString *)domainName;


///-----------------------------------
/// @name Querying Items
///-----------------------------------

/**
 */
- (NSArray *)fetchItems;

/**
 */
- (NSArray *)fetchItemsWithLimit:(NSUInteger)limit;

/**
 */
- (NSArray *)fetchItemsWithNames:(NSArray *)names;

/**
 */
- (NSArray *)fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments;

/**
 */
- (NSArray *)fetchItemsWithPredicateFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments limit:(NSUInteger)limit;

/**
 */
- (NSArray *)fetchItemsWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments range:(NSRange)range sortedByKeys:(NSArray*)keys;

/**
 */
- (NSArray *)fetchAttributesWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments;

/**
 */
- (NSArray *)fetchAttributesWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments range:(NSRange)range sortedByKeys:(NSArray*)keys;

/**
 */
- (NSUInteger)countItems;


///-----------------------------------
/// @name Removing Items
///-----------------------------------

/**
 */
- (void)removeItems:(NSArray *)items;

/**
 */
- (void)removeItemsWithNames:(NSArray *)names;


///-----------------------------------
/// @name Querying Attributes
///-----------------------------------

/**
 */
- (NSArray *)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName;

/**
 */
- (id)fetchAttributesWithNames:(NSArray *)names forItemNamed:(NSString *)itemName resultType:(CKStoreResultType)resultType;

///-----------------------------------
/// @name Inserting Attributes 
///-----------------------------------

- (NSString *)insertAttributesWithValuesForNames:(NSDictionary *)attributes forItemNamed:(NSString *)itemName;


@end


