//
//  CKNSObject+CKStore.h
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Cloudkit/CKModelObject.h>

@class CKStoreRequest;
@class CKItem;

@interface CKModelObject (CKStoreAddition)

- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain;
- (CKItem*)saveToDomainNamed:(NSString*)domain;
+ (CKItem *)createItemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain;
+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain;
+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain createIfNotFound:(BOOL)createIfNotFound;
+ (CKItem*)itemWithUniqueId:(NSString*) uniqueId inDomainNamed:(NSString*)domain;

+ (CKStoreRequest*)requestForObjectsOfType:(Class)type inDomainNamed:(NSString*)domain range:(NSRange)range;

@end