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

@property (nonatomic,retain,readonly) CKDocumentCollectionController* objectController;
@property (nonatomic,retain,readonly) NSMutableArray* headerCellDescriptors;
@property (nonatomic,retain,readonly) NSMutableArray* footerCellDescriptors;

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings headerTitle:(NSString*)title;

+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings displayFeedSourceCell:(BOOL)displayFeedSourceCell;
+ (CKFormDocumentCollectionSection*)sectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings headerTitle:(NSString*)title displayFeedSourceCell:(BOOL)displayFeedSourceCell;

- (CKFormCellDescriptor*)addFooterCellDescriptor:(CKFormCellDescriptor*)descriptor;
- (void)removeFooterCellDescriptor:(CKFormCellDescriptor*)descriptor;
- (CKFormCellDescriptor*)addHeaderCellDescriptor:(CKFormCellDescriptor*)descriptor;
- (void)removeHeaderCellDescriptor:(CKFormCellDescriptor*)descriptor;

@end
