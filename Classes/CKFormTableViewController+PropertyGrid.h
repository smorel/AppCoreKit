//
//  CKFormTableViewController+PropertyGrid.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-29.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKObjectProperty.h"


@interface CKFormTableViewController(CKPropertyGrid)

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title;
- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden;

- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title readOnly:(BOOL)readOnly;
- (CKFormSectionBase*)addSectionWithObject:(id)object headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title readOnly:(BOOL)readOnly;
- (CKFormSectionBase*)addSectionWithObject:(id)object propertyFilter:(NSString*)filter headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title readOnly:(BOOL)readOnly;
- (CKFormSectionBase*)addSectionWithObject:(id)object properties:(NSArray*)properties headerTitle:(NSString*)title hidden:(BOOL)hidden readOnly:(BOOL)readOnly;

@end


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