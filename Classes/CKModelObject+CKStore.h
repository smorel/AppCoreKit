//
//  CKNSObject+CKStore.h
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKStoreRequest;
@class CKItem;

extern NSMutableDictionary* CKModelObjectManager;


/** TODO
 */
@interface CKModelObject (CKStoreAddition)

- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain;

- (CKItem*)saveToDomainNamed:(NSString*)domain;
- (void)deleteFromDomainNamed:(NSString*)domain;
+ (CKItem *)createItemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain;

+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain;
+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain createIfNotFound:(BOOL)createIfNotFound;
+ (CKItem*)itemWithUniqueId:(NSString*) uniqueId inDomainNamed:(NSString*)domain;

+ (NSArray*)itemsWithClass:(Class)type withPropertiesAndValues:(NSDictionary*)attributes inDomainNamed:(NSString*)domain;

+ (CKModelObject*)objectWithUniqueId:(NSString*)uniqueId;
+ (CKModelObject*)loadObjectWithUniqueId:(NSString*)uniqueId;
+ (void)registerObject:(CKModelObject*) object withUniqueId:(NSString*)uniqueId;

@end