//
//  CKFormBindedCollectionSection.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKCollection.h"
#import "CKCollectionCellControllerFactory.h"
#import "CKCollectionController.h"

@class CKTableViewCellController;

/**
 */
@interface CKFormBindedCollectionSection : CKFormSectionBase<CKObjectControllerDelegate>

///-----------------------------------
/// @name Creating Section Objects
///-----------------------------------

/**
 */
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory;

/**
 */
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory headerTitle:(NSString*)title;

/**
 */
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory appendSpinnerAsFooterCell:(BOOL)appendSpinnerAsFooterCell;

/**
 */
+ (CKFormBindedCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory headerTitle:(NSString*)title appendSpinnerAsFooterCell:(BOOL)appendSpinnerAsFooterCell;

///-----------------------------------
/// @name Initializing Section Objects
///-----------------------------------

/**
 */
- (id)initWithCollection:(CKCollection*)collection factory:(CKCollectionCellControllerFactory*)factory;

///-----------------------------------
/// @name Managing footer cell controllers
///-----------------------------------

/**
 */
@property (nonatomic,retain,readonly) NSMutableArray* footerCellControllers;

/**
 */
- (void)addFooterCellController:(CKTableViewCellController*)controller;

/**
 */
- (void)removeFooterCellController:(CKTableViewCellController*)controller;

///-----------------------------------
/// @name Managing header cell controllers
///-----------------------------------

/**
 */
@property (nonatomic,retain,readonly) NSMutableArray* headerCellControllers;

/**
 */
- (void)addHeaderCellController:(CKTableViewCellController*)controller;

/**
 */
- (void)removeHeaderCellController:(CKTableViewCellController*)controller;

///-----------------------------------
/// @name Customizing the display
///-----------------------------------

/**
 */
@property (nonatomic,assign) NSInteger maximumNumberOfObjectsToDisplay;

@end