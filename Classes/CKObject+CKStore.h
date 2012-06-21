//
//  CKNSObject+CKStore.h
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"

@interface CKObject (CKStoreAddition)

- (void)saveObjectToDomainNamed:(NSString*)domain;
- (void)saveObjectToDomainNamed:(NSString*)domain recursive:(BOOL)recursive;

- (void)removeObjectFromDomainNamed:(NSString*)domain;

+ (CKObject*)objectWithUniqueId:(NSString*)uniqueId;
+ (CKObject*)loadObjectWithUniqueId:(NSString*)uniqueId;

@end