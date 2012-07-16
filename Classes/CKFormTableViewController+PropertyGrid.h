//
//  CKFormTableViewController+PropertyGrid.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKObjectProperty.h"

@interface CKFormCellDescriptor(CKPropertyGrid)

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath;
+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath readOnly:(BOOL)readOnly;
+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property;
+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property readOnly:(BOOL)readOnly;

@end

@interface CKFormSection(CKPropertyGrid)

+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden;
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden;
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden;

+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly;
+ (CKFormSection*)sectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly;
+ (CKFormSection*)sectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly;
+ (CKFormSection*)sectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

@end



/********************************* DEPRECATED *********************************
 */
@interface CKFormTableViewController(DEPRECATED_IN_CLOUDKIT_1_7_11_AND_LATER)

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden DEPRECATED_ATTRIBUTE;

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly DEPRECATED_ATTRIBUTE;

@end
