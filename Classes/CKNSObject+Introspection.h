//
//  ObjectIntrospection.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKClassPropertyDescriptor.h"

/** TODO
 */
@interface NSObject (CKNSObjectIntrospection)

- (NSString*)className;

+ (NSArray*)allClasses;
+ (NSArray*)allClassesKindOfClass:(Class)filter;

+ (BOOL)isClass:(Class)type kindOfClass:(Class)parentType;
+ (BOOL)isClass:(Class)type kindOfClassNamed:(NSString*)parentClassName;
+ (BOOL)isClass:(Class)type exactKindOfClass:(Class)parentType;
+ (BOOL)isClass:(Class)type exactKindOfClassNamed:(NSString*)parentClassName;

- (NSArray*)allViewsPropertyDescriptors;
- (NSArray*)allPropertyDescriptors;
- (NSArray*)allPropertyNames;

+ (NSArray*)superClassesForClass:(Class)c;

+ (CKClassPropertyDescriptor*) propertyDescriptorForClass:(Class)c key:(NSString*)key;
+ (CKClassPropertyDescriptor*) propertyDescriptorForObject:(id)object keyPath:(NSString*)keyPath;

- (CKClassPropertyDescriptor*) propertyDescriptorForKeyPath:(NSString*)keyPath;

@end


/********************************* DEPRECATED *********************************
 */

@interface NSObject (CKNSObjectIntrospection_DEPRECATED_IN_CLOUDKIT_1_7_15_AND_LATER)

+ (BOOL)isKindOf:(Class)type parentType:(Class)parentType DEPRECATED_ATTRIBUTE;
+ (BOOL)isKindOf:(Class)type parentClassName:(NSString*)parentClassName DEPRECATED_ATTRIBUTE;
+ (BOOL)isExactKindOf:(Class)type parentType:(Class)parentType DEPRECATED_ATTRIBUTE;
+ (BOOL)isExactKindOf:(Class)type parentClassName:(NSString*)parentClassName DEPRECATED_ATTRIBUTE;

+ (CKClassPropertyDescriptor*) propertyDescriptor:(Class)c forKey:(NSString*)name DEPRECATED_ATTRIBUTE;
+ (CKClassPropertyDescriptor*) propertyDescriptor:(id)object forKeyPath:(NSString*)keyPath DEPRECATED_ATTRIBUTE;

@end