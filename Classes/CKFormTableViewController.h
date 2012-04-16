//
//  CKFormTableViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-06.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKFormSection.h"
#import "CKFormBindedCollectionSection.h"

/** TODO
 */
@interface CKFormTableViewController : CKBindedTableViewController {
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

///-----------------------------------
/// @name Clearing CKFormTableViewController
///-----------------------------------

- (void)clear;

///-----------------------------------
/// @name Creating or inserting the sections
///-----------------------------------

- (NSArray*)addSections:(NSArray *)sections;
- (CKFormSectionBase *)insertSection:(CKFormSectionBase*)section atIndex:(NSInteger)index;
- (CKFormSectionBase *)removeSectionAtIndex:(NSInteger)index;

- (void)setSections:(NSArray*)sections hidden:(BOOL)hidden;

///-----------------------------------
/// @name Accessing the sections
///-----------------------------------

- (CKFormSectionBase *)sectionAtIndex:(NSUInteger)index;
- (NSInteger)indexOfSection:(CKFormSectionBase *)section;

- (NSInteger)numberOfVisibleSections;
- (CKFormSectionBase*)visibleSectionAtIndex:(NSInteger)index;
- (NSInteger)indexOfVisibleSection:(CKFormSectionBase*)section;

@end


//Adds extensions here to avoid importing to much files in client projects
#import "CKTableViewCellController+PropertyGrid.h"
#import "CKTableViewCellController+Menus.h"
