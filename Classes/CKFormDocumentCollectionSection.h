//
//  CKFormDocumentCollectionSection.h
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
@interface CKFormDocumentCollectionSection : CKFormSectionBase<CKObjectControllerDelegate>{
	CKCollectionController* _objectController;
	CKItemViewControllerFactory* _controllerFactory;
	
	NSMutableArray* _headerCellDescriptors;
	NSMutableArray* _footerCellDescriptors;
	NSMutableArray* _changeSet;
	
	BOOL sectionUpdate;
}

@property (nonatomic,retain,readonly) NSMutableArray* headerCellDescriptors;
@property (nonatomic,retain,readonly) NSMutableArray* footerCellDescriptors;
@property (nonatomic,retain,readonly) CKCollectionController* objectController;

//Initialization and constructors
- (id)initWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory appendCollectionCellControllerAsFooterCell:(BOOL)appendCollectionCellControllerAsFooterCell;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title appendCollectionCellControllerAsFooterCell:(BOOL)appendCollectionCellControllerAsFooterCell;

//Cell Descriptor API
- (CKFormCellDescriptor*)addFooterCellDescriptor:(CKFormCellDescriptor*)descriptor;
- (void)removeFooterCellDescriptor:(CKFormCellDescriptor*)descriptor;
- (CKFormCellDescriptor*)addHeaderCellDescriptor:(CKFormCellDescriptor*)descriptor;
- (void)removeHeaderCellDescriptor:(CKFormCellDescriptor*)descriptor;

//Cell Controller API
- (CKFormCellDescriptor*)addFooterCellController:(CKTableViewCellController*)controller;
- (void)removeFooterCellController:(CKTableViewCellController*)controller;
- (CKFormCellDescriptor*)addHeaderCellController:(CKTableViewCellController*)controller;
- (void)removeHeaderCellController:(CKTableViewCellController*)controller;

- (CKFormCellDescriptor*)headerCellDescriptorForCellController:(CKTableViewCellController*)controller;
- (CKFormCellDescriptor*)footerCellDescriptorForCellController:(CKTableViewCellController*)controller;

@end