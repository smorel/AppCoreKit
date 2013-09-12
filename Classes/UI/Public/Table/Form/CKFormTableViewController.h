//
//  CKFormTableViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableCollectionViewController.h"
#import "CKFormSectionBase.h"
#import "CKFormSection.h"
#import "CKFormBindedCollectionSection.h"

/**
 */
@interface CKFormTableViewController : CKTableCollectionViewController 

///-----------------------------------
/// @name Initializing CKFormTableViewController Objects
///-----------------------------------

/**
 */
- (id)initWithSections:(NSArray*)sections;

///-----------------------------------
/// @name Clearing CKFormTableViewController
///-----------------------------------

/**
 */
- (void)clear;

///-----------------------------------
/// @name Inserting sections
///-----------------------------------

/**
 */
- (NSArray*)addSections:(NSArray *)sections;

/**
 */
- (CKFormSectionBase *)insertSection:(CKFormSectionBase*)section atIndex:(NSInteger)index;

///-----------------------------------
/// @name Removing sections
///-----------------------------------

/**
 */
- (CKFormSectionBase *)removeSectionAtIndex:(NSInteger)index;

///-----------------------------------
/// @name Hiding/Showing Sections
///-----------------------------------

/**
 */
- (void)setSections:(NSArray*)sections hidden:(BOOL)hidden;

/** Enabling this flag will hides the section if there is no cell controller in it.
 */
@property (nonatomic,assign) BOOL autoHideSections;


/** Enabling this flag will hides the section header if there is less than 2 cell controllers in it.
 */
@property (nonatomic,assign) BOOL autoHideSectionHeaders;

///-----------------------------------
/// @name Querying Sections
///-----------------------------------

/**
 */
@property (nonatomic,retain, readonly) NSMutableArray* sections;

/**
 */
- (CKFormSectionBase *)sectionAtIndex:(NSUInteger)index;

/**
 */
- (NSInteger)indexOfSection:(CKFormSectionBase *)section;

/**
 */
- (NSUInteger)numberOfVisibleSections;

/**
 */
- (CKFormSectionBase*)visibleSectionAtIndex:(NSInteger)index;

/**
 */
- (NSInteger)indexOfVisibleSection:(CKFormSectionBase*)section;

///-----------------------------------
/// @name Validating forms
///-----------------------------------

/** Enabling this flag will be propagated to any cell controller representing CKProperty and display a red arrow on the right for any property that is not valid.
 */
@property (nonatomic,assign) BOOL validationEnabled;

/**
 */
- (NSSet*)allEditingProperties;

@end
