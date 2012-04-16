//
//  CKTableViewCellController+PropertyGrid.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-29.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKProperty.h"

@interface CKTableViewCellController(CKPropertyGrid)

+ (CKTableViewCellController*)cellControllerWithObject:(id)object keyPath:(NSString*)keyPath;
+ (CKTableViewCellController*)cellControllerWithObject:(id)object keyPath:(NSString*)keyPath readOnly:(BOOL)readOnly;
+ (CKTableViewCellController*)cellControllerWithProperty:(CKProperty*)property;
+ (CKTableViewCellController*)cellControllerWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly;

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
