//
//  CKNSObject+CKStore.h
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"

@class CKStoreRequest;
@class CKItem;

extern NSMutableDictionary* CKObjectManager;


/** TODO
 */
@interface CKObject (CKStoreAddition)

- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain;

- (CKItem*)saveToDomainNamed:(NSString*)domain;
- (CKItem*)saveToDomainNamed:(NSString*)domain recursive:(BOOL)recursive;

- (void)deleteFromDomainNamed:(NSString*)domain;
+ (CKItem *)createItemWithObject:(CKObject*)object inDomainNamed:(NSString*)domain;

+ (CKItem*)itemWithObject:(CKObject*)object inDomainNamed:(NSString*)domain;
+ (CKItem*)itemWithObject:(CKObject*)object inDomainNamed:(NSString*)domain createIfNotFound:(BOOL)createIfNotFound;
+ (CKItem*)itemWithUniqueId:(NSString*) uniqueId inDomainNamed:(NSString*)domain;

+ (NSArray*)itemsWithClass:(Class)type withPropertiesAndValues:(NSDictionary*)attributes inDomainNamed:(NSString*)domain;

+ (CKObject*)objectWithUniqueId:(NSString*)uniqueId;
+ (CKObject*)loadObjectWithUniqueId:(NSString*)uniqueId;
+ (void)registerObject:(CKObject*) object withUniqueId:(NSString*)uniqueId;

@end