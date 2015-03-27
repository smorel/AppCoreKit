//
//  CKProperty.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Runtime.h"
#import "CKClassPropertyDescriptor.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

/** CKProperty is a wrapper around key-value coding. It allow to set/get value for an object/dictionary keypath and manage some introspection calls to provides an easy interface to access attributes and class property descriptors. Moreover it provides some methods to work with NSArray properties (insertObjects/removeObjectsAtIndexes/removeAllObjects/count).
 */
@interface CKProperty : NSObject<NSCopying> 

///-----------------------------------
/// @name Creating property objects
///-----------------------------------

/**
 */
+ (CKProperty*)weakPropertyWithObject:(id)object keyPath:(NSString*)keyPath;

/**
 */
+ (CKProperty*)weakPropertyWithObject:(id)object;

/**
 */
+ (CKProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath;

/**
 */
+ (CKProperty*)propertyWithObject:(id)object;

/**
 */
+ (CKProperty*)propertyWithDictionary:(id)dictionary key:(id)key;

///-----------------------------------
/// @name Initializing property objects
///-----------------------------------

/**
 */
- (id)initWithObject:(id)object keyPath:(NSString*)keyPath weak:(BOOL)weak;

/**
 */
- (id)initWithObject:(id)object weak:(BOOL)weak;

/**
 */
- (id)initWithDictionary:(NSDictionary*)dictionary key:(id)key;


///-----------------------------------
/// @name Accessing property attributes 
///-----------------------------------

/**
 */
@property (nonatomic,assign,readonly,getter = isWeak) BOOL weak;

/**
 */
@property (nonatomic,retain,readonly) id object;

/**
 */
@property (nonatomic,retain,readonly) id keyPath;

/**
 */
@property (nonatomic,readonly) NSString* name;

/**
 */
@property (nonatomic,retain,readonly) CKClassPropertyDescriptor* descriptor;

/**
 */
- (Class)type;

/**
 */
- (BOOL)isReadOnly;

/**
 */
- (BOOL)isNumber;

/**
 */
- (BOOL)isBool;

///-----------------------------------
/// @name Accessing property extended attributes 
///-----------------------------------

/**
 */
- (CKPropertyExtendedAttributes*)extendedAttributes;

///-----------------------------------
/// @name Manipulating property value
///-----------------------------------

/**
 */
@property (nonatomic,assign) id value;

///-----------------------------------
/// @name Manipulating Container property
///-----------------------------------

/**
 */
- (BOOL)isContainer;

/**
 */
- (void)insertObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes;

/**
 */
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes;

/**
 */
- (void)removeAllObjects;

/**
 */
- (void)addObject:(id)value;

/**
 */
- (void)removeObject:(id)value;

/**
 */
- (BOOL)containsObject:(id)value;

/**
 */
- (NSInteger)count;

/**
 */
- (BOOL)isKVCComplient;

@end
