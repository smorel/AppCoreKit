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
	CKDocumentCollectionController* _objectController;
	CKItemViewControllerFactory* _controllerFactory;
	
	NSMutableArray* _headerCellDescriptors;
	NSMutableArray* _footerCellDescriptors;
	NSMutableArray* _changeSet;
	
	BOOL sectionUpdate;
}

@property (nonatomic,retain,readonly) NSMutableArray* headerCellDescriptors;
@property (nonatomic,retain,readonly) NSMutableArray* footerCellDescriptors;
@property (nonatomic,retain,readonly) CKDocumentCollectionController* objectController;

//Initialization and constructors
- (id)initWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory displayFeedSourceCell:(BOOL)displayFeedSourceCell;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory headerTitle:(NSString*)title displayFeedSourceCell:(BOOL)displayFeedSourceCell;

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

/********************************* DEPRECATED *********************************
 */

@interface CKFormDocumentCollectionSection(DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings DEPRECATED_ATTRIBUTE;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings DEPRECATED_ATTRIBUTE;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings headerTitle:(NSString*)title DEPRECATED_ATTRIBUTE;

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings displayFeedSourceCell:(BOOL)displayFeedSourceCell DEPRECATED_ATTRIBUTE;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings headerTitle:(NSString*)title displayFeedSourceCell:(BOOL)displayFeedSourceCell DEPRECATED_ATTRIBUTE;

@end