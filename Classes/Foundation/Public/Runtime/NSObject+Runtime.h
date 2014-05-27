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
+ (NSArray*)allClassesConformToProtocol:(Protocol*)protocol;

/**
 */
+ (NSArray*)superClassesForClass:(Class)c;

/**
 */
+ (NSArray*)allClassesWithPrefix:(NSString*)prefix;

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
+ (NSArray*)allViewsPropertyDescriptorsForClass:(Class)c;

/**
 */
+ (NSArray*)allPropertyDescriptorsForClass:(Class)c;

/**
 */
+ (NSArray*)allPropertyNamesForClass:(Class)c;

/**
 */
- (BOOL)hasPropertyNamed:(NSString*)propertyName;


///-----------------------------------
/// @name Accessing Methods
///-----------------------------------

/** returns an NSArray containing:
     NSValue* v = [NSValue valueWithBytes:&theMethod objCType:@encode(Method)];
 
 To get the Method struct do as follow:
     Method method;
     [v getValue:&method];
 
 */
+ (NSArray*)allMethodsForClass:(Class)c;

/**
 */
+ (NSArray*)allMethodNamesForClass:(Class)c;

/** returns an NSArray containing:
 NSValue* v = [NSValue valueWithBytes:&theMethod objCType:@encode(Method)];
 
 To get the Method struct do as follow:
 Method method;
 [v getValue:&method];
 
 */
- (NSArray*)allMethods;

@end
