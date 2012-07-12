//
//  CKFormSection+PropertyGrid.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKFormSection.h"

/**
 */
@interface CKFormSection(CKPropertyGrid)

///-----------------------------------
/// @name Creating Section Objects
///-----------------------------------

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly;

/**
 */
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

@end
