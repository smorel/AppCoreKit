//
//  CKFormSection.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKFormSectionBase.h"

@class CKTableViewCellController;

/**
 */
@interface CKFormSection : CKFormSectionBase

///-----------------------------------
/// @name Creating Section Objects
///-----------------------------------

/**
 */
+ (CKFormSection*)section;

/**
 */
+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithHeaderView:(UIView*)view;

/**
 */
+ (CKFormSection*)sectionWithFooterTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithFooterView:(UIView*)view;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;


///-----------------------------------
/// @name Initializing Section Objects
///-----------------------------------

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers;

///-----------------------------------
/// @name Querying the Section
///-----------------------------------

/**
 */
@property (nonatomic,retain, readonly) NSArray* cellControllers;

/**
 */
- (NSInteger)count;

/**
 */
- (CKTableViewCellController*)cellControllerWithValue:(id)value;

///-----------------------------------
/// @name Inserting Cell Controllers
///-----------------------------------

/**
 */
- (void)insertCellControllers:(NSArray *)controllers atIndexes:(NSIndexSet*)indexes;

/**
 */
- (void)insertCellController:(CKTableViewCellController *)controller atIndex:(NSUInteger)index;

/**
 */
- (void)addCellController:(CKTableViewCellController *)controller;

///-----------------------------------
/// @name Removing Cell Controllers
///-----------------------------------

/**
 */
- (void)removeCellControllers:(NSArray *)controllers;

/**
 */
- (void)removeCellController:(CKTableViewCellController *)controller;

/**
 */
- (void)removeCellControllersAtIndexes:(NSIndexSet*)indexes;

/**
 */
- (void)removeCellControllerAtIndex:(NSUInteger)index;

@end

#import "CKFormSection+PropertyGrid.h"