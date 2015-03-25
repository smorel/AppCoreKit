//
//  CKSection+Property.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

@interface CKSection (Property)

///-----------------------------------
/// @name Creating Section Objects
///-----------------------------------

/**
 */
+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title;

/**
 */
+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden;

/**
 */
+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title;

/**
 */
+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden;

/**
 */
+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title;

/**
 */
+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden;

/**
 */
+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly;

/**
 */
+ (CKSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

/**
 */
+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly;

/**
 */
+ (CKSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

/**
 */
+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly;

/**
 */
+ (CKSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

@end
