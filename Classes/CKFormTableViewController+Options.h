//
//  CKFormTableViewController+Options.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKObjectProperty.h"

@interface CKFormCellDescriptor (CKOptions)

+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled;
+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath valuesAndLabels:(NSDictionary*)valuesAndLabels;
+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled readOnly:(BOOL)readOnly;
+ (CKFormCellDescriptor*)cellDescriptorWithObject:(id)object keyPath:(NSString*)keyPath valuesAndLabels:(NSDictionary*)valuesAndLabels readOnly:(BOOL)readOnly;

+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled;
+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property valuesAndLabels:(NSDictionary*)valuesAndLabels;
+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property enumDescriptor:(CKEnumDescriptor*)enumDescriptor multiSelectionEnabled:(BOOL)multiSelectionEnabled readOnly:(BOOL)readOnly;
+ (CKFormCellDescriptor*)cellDescriptorWithProperty:(CKObjectProperty*)property valuesAndLabels:(NSDictionary*)valuesAndLabels readOnly:(BOOL)readOnly;

@end
