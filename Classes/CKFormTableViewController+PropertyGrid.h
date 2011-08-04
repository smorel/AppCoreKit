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

@end


@interface CKFormCellDescriptor(CKPropertyGrid)

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath;
+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property;

@end