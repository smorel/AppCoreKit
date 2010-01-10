//
//  CKStore.h
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
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

- (id)initWithDomainName:(NSString *)domainName;

- (NSArray *)fetchItemsWithPredicate:(NSPredicate *)predicate;
- (NSArray *)fetchAttributesForItemNamed:(NSString *)itemName withNames:(NSArray *)attributesNames;
- (id)fetchAttributesForItemNamed:(NSString *)itemName withNames:(NSArray *)attributesNames resultType:(CKStoreResultType)resultType;
- (void)putAttributes:(NSDictionary *)attributes forItemNamed:(NSString *)itemName;

@end
