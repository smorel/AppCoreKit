//
//  CKFormTableViewController.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKFormSection.h"
#import "CKFormDocumentCollectionSection.h"

/** TODO
 */
@interface CKFormTableViewController : CKObjectTableViewController {
	NSMutableArray* _sections;
	BOOL _autoHideSections;
	BOOL _autoHideSectionHeaders;
	BOOL reloading;
    BOOL _validationEnabled;
}
@property (nonatomic,retain, readonly) NSMutableArray* sections;
@property (nonatomic,assign) BOOL autoHideSections;
@property (nonatomic,assign) BOOL autoHideSectionHeaders;
@property (nonatomic,assign) BOOL validationEnabled;

///-----------------------------------
/// @name Initializing CKFormTableViewController
///-----------------------------------

- (id)initWithSections:(NSArray*)sections;
- (id)initWithSections:(NSArray*)sections withNibName:(NSString*)nibName;

///-----------------------------------
/// @name Clearing CKFormTableViewController
///-----------------------------------

- (void)clear;

///-----------------------------------
/// @name Creating or inserting the sections
///-----------------------------------

- (NSArray*)addSections:(NSArray *)sections;
- (void)setSections:(NSArray*)sections hidden:(BOOL)hidden;

- (CKFormSectionBase *)insertSection:(CKFormSectionBase*)section atIndex:(NSInteger)index;
- (CKFormSectionBase *)removeSectionAtIndex:(NSInteger)index;

- (CKFormSection *)insertSectionWithCellDescriptors:(NSArray *)cellDescriptors atIndex:(NSInteger)index;
- (CKFormSection *)insertSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle  atIndex:(NSInteger)index;
- (CKFormDocumentCollectionSection *)insertSectionWithCollection:(CKDocumentCollection*)collection factory:(CKItemViewControllerFactory*)factory  atIndex:(NSInteger)index;


///-----------------------------------
/// @name Accessing the sections
///-----------------------------------

- (CKFormSectionBase *)sectionAtIndex:(NSUInteger)index;
- (NSInteger)indexOfSection:(CKFormSectionBase *)section;

- (NSInteger)numberOfVisibleSections;
- (CKFormSectionBase*)visibleSectionAtIndex:(NSInteger)index;
- (NSInteger)indexOfVisibleSection:(CKFormSectionBase*)section;

@end


/********************************* DEPRECATED *********************************
 */

@interface CKFormTableViewController(DEPRECATED_IN_CLOUDKIT_VERSION_1_7_AND_LATER)
- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors DEPRECATED_ATTRIBUTE;
- (CKFormSection *)addSectionWithCellDescriptors:(NSArray *)cellDescriptors headerTitle:(NSString *)headerTitle DEPRECATED_ATTRIBUTE;
- (CKFormSectionBase*)addSection:(CKFormSectionBase *)section DEPRECATED_ATTRIBUTE;
- (CKFormDocumentCollectionSection *)addSectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings DEPRECATED_ATTRIBUTE;
@end


@interface CKFormTableViewController(DEPRECATED_IN_CLOUDKIT_VERSION_1_7_14_AND_LATER)
- (CKFormDocumentCollectionSection *)insertSectionWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings  atIndex:(NSInteger)index DEPRECATED_ATTRIBUTE;
@end

//Adds extensions here to avoid importing to much files in client projects
#import "CKFormTableViewController+PropertyGrid.h"
#import "CKFormTableViewController+Menus.h"
