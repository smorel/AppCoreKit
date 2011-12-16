//
//  CKFormSection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKFormCellDescriptor.h"

@class CKFormCellDescriptor;

/** TODO
 */
@interface CKFormSection : CKFormSectionBase{
	
	NSMutableArray* _cellDescriptors;
}

- (NSInteger)count;

//Cell Descriptors API

- (id)initWithCellDescriptors:(NSArray*)cellDescriptors headerTitle:(NSString*)title;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors headerView:(UIView*)view;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors footerTitle:(NSString*)title;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors footerView:(UIView*)view;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors;

+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerView:(UIView*)view;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors footerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors footerView:(UIView*)view;

- (CKFormCellDescriptor*)insertCellDescriptor:(CKFormCellDescriptor *)cellDescriptor atIndex:(NSUInteger)index;
- (CKFormCellDescriptor*)addCellDescriptor:(CKFormCellDescriptor *)cellDescriptor;
- (void)removeCellDescriptor:(CKFormCellDescriptor *)cellDescriptor;
- (void)removeCellDescriptorAtIndex:(NSUInteger)index;

//cell controllers API

- (id)initWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;
- (id)initWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;
- (id)initWithCellControllers:(NSArray*)cellcontrollers;

+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;

- (CKFormCellDescriptor*)insertCellController:(CKTableViewCellController *)controller atIndex:(NSUInteger)index;
- (CKFormCellDescriptor*)addCellController:(CKTableViewCellController *)controller;
- (void)removeCellController:(CKTableViewCellController *)controller;
- (void)removeCellControllerAtIndex:(NSUInteger)index;

- (CKFormCellDescriptor*)cellDescriptorForCellController:(CKTableViewCellController*)controller;

//Base API

+ (CKFormSection*)section;
+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title;
+ (CKFormSection*)sectionWithHeaderView:(UIView*)view;
+ (CKFormSection*)sectionWithFooterTitle:(NSString*)title;
+ (CKFormSection*)sectionWithFooterView:(UIView*)view;


@end