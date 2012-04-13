//
//  CKNSObject+CKRuntime.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKClassPropertyDescriptor.h"

/** TODO
 */
@interface NSObject (CKRuntime)

+ (NSArray*)allClasses;
+ (NSArray*)allClassesKindOfClass:(Class)filter;
+ (NSArray*)superClassesForClass:(Class)c;

+ (BOOL)isClass:(Class)type kindOfClass:(Class)parentType;
+ (BOOL)isClass:(Class)type kindOfClassNamed:(NSString*)parentClassName;
+ (BOOL)isClass:(Class)type exactKindOfClass:(Class)parentType;
+ (BOOL)isClass:(Class)type exactKindOfClassNamed:(NSString*)parentClassName;

+ (CKClassPropertyDescriptor*) propertyDescriptorForClass:(Class)c key:(NSString*)key;
+ (CKClassPropertyDescriptor*) propertyDescriptorForObject:(id)object keyPath:(NSString*)keyPath;


- (NSString*)className;

- (CKClassPropertyDescriptor*) propertyDescriptorForKeyPath:(NSString*)keyPath;

- (NSArray*)allViewsPropertyDescriptors;
- (NSArray*)allPropertyDescriptors;
- (NSArray*)allPropertyNames;

@end
