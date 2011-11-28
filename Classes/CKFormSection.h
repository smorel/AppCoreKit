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

@property (nonatomic,retain) NSArray* cellDescriptors;

- (id)initWithCellDescriptors:(NSArray*)cellDescriptors headerTitle:(NSString*)title;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors headerView:(UIView*)view;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors footerTitle:(NSString*)title;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors footerView:(UIView*)view;
- (id)initWithCellDescriptors:(NSArray*)cellDescriptors;

+ (CKFormSection*)section;
+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title;
+ (CKFormSection*)sectionWithHeaderView:(UIView*)view;
+ (CKFormSection*)sectionWithFooterTitle:(NSString*)title;
+ (CKFormSection*)sectionWithFooterView:(UIView*)view;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors headerView:(UIView*)view;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors footerTitle:(NSString*)title;
+ (CKFormSection*)sectionWithCellDescriptors:(NSArray*)cellDescriptors footerView:(UIView*)view;

- (CKFormCellDescriptor*)insertCellDescriptor:(CKFormCellDescriptor *)cellDescriptor atIndex:(NSUInteger)index;
- (CKFormCellDescriptor*)addCellDescriptor:(CKFormCellDescriptor *)cellDescriptor;
- (void)removeCellDescriptor:(CKFormCellDescriptor *)cellDescriptor;
- (void)removeCellDescriptorAtIndex:(NSUInteger)index;

@end