//
//  NSObject+Runtime.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKClassPropertyDescriptor.h"

/**
 */
@interface NSObject (CKRuntime)

///-----------------------------------
/// @name Accessing Classes registered in the runtime
///-----------------------------------

/**
 */
+ (NSArray*)allClasses;

/**
 */
+ (NSArray*)allClassesKindOfClass:(Class)filter;

/**
 */
+ (NSArray*)superClassesForClass:(Class)c;

///-----------------------------------
/// @name Identifying Classes
///-----------------------------------

/**
 */
- (NSString*)className;


///-----------------------------------
/// @name Testing Class Inheritance
///-----------------------------------

/**
 */
+ (BOOL)isClass:(Class)type kindOfClass:(Class)parentType;

/**
 */
+ (BOOL)isClass:(Class)type kindOfClassNamed:(NSString*)parentClassName;

/**
 */
+ (BOOL)isClass:(Class)type exactKindOfClass:(Class)parentType;

/**
 */
+ (BOOL)isClass:(Class)type exactKindOfClassNamed:(NSString*)parentClassName;


///-----------------------------------
/// @name Accessing properties
///-----------------------------------

/**
 */
+ (CKClassPropertyDescriptor*) propertyDescriptorForClass:(Class)c key:(NSString*)key;

/**
 */
+ (CKClassPropertyDescriptor*) propertyDescriptorForObject:(id)object keyPath:(NSString*)keyPath;

/**
 */
- (CKClassPropertyDescriptor*) propertyDescriptorForKeyPath:(NSString*)keyPath;

/**
 */
- (NSArray*)allViewsPropertyDescriptors;

/**
 */
- (NSArray*)allPropertyDescriptors;

/**
 */
- (NSArray*)allPropertyNames;

/**
 */
- (BOOL)hasPropertyNamed:(NSString*)propertyName;

@end
