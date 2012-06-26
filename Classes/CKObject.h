//
//  CKObject.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKClassPropertyDescriptor.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKNSObject+CKRuntime.h"

/**
 */
@protocol CKMigrating

///-----------------------------------
/// @name Reacting to class changes when deserializing an object
///-----------------------------------

/**
 */
- (void)propertyChanged:(CKClassPropertyDescriptor*)property serializedObject:(id)object;

/**
 */
- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object;

/**
 */
- (void)propertyAdded:(CKClassPropertyDescriptor*)property;
@end


/**
 */
@interface CKObject : NSObject<NSCoding,NSCopying,CKMigrating> 

///-----------------------------------
/// @name Creating objects
///-----------------------------------

/** 
 */
+ (id)object;

///-----------------------------------
/// @name Initializing objects
///-----------------------------------

/** Overload this method to initialize your objects property whatever initializer is called. Do not forget to call the super implementation first.
 */
- (void)postInit;


///-----------------------------------
/// @name Identifying the object in CKStore
///-----------------------------------

/** This property is automatically set when serializing an object in core data
 */
@property (nonatomic,copy) NSString* uniqueId;

///-----------------------------------
/// @name Identifying the object at runtime
///-----------------------------------

/** 
 */
@property (nonatomic,copy) NSString* objectName;

///-----------------------------------
/// @name Getting the object status when serializing in CKStore
///-----------------------------------

/** 
 */
@property (nonatomic,readonly) BOOL isSaving;

/** 
 */
@property (nonatomic,readonly) BOOL isLoading;

@end


/**
 */
@interface NSObject (CKObject)

///-----------------------------------
/// @name Copying an object
///-----------------------------------

/** 
 */
- (void)copyPropertiesFromObject : (id)other;

///-----------------------------------
/// @name Comparing an object
///-----------------------------------

/** 
 */
- (BOOL)isEqualToObject:(id)other;

@end

#import "CKNSObject+Validation.h"
#import "CKNSObject+CKSingleton.h"
