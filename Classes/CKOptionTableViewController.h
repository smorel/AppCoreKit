//
//  CKOptionTableViewController.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CKFormTableViewController.h"


@class CKOptionTableViewController;


/**
 */
@protocol CKOptionTableViewControllerDelegate

///-----------------------------------
/// @name Managing the selection
///-----------------------------------

/**
 */
- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index;

@end





typedef void(^CKOptionTableViewControllerSelectionBlock)(CKOptionTableViewController* tableViewController,NSInteger index);


/**
 */
@interface CKOptionTableViewController : CKFormTableViewController 

///-----------------------------------
/// @name Initializing CKOptionTableViewController Objects
///-----------------------------------

/**
 */
- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index;

/**
 */
- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSArray*)selected multiSelectionEnabled:(BOOL)multiSelectionEnabled;

/**
 */
- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index style:(UITableViewStyle)style;

/**
 */
- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSArray*)selected multiSelectionEnabled:(BOOL)multiSelectionEnabled style:(UITableViewStyle)style;

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property (nonatomic, assign) id optionTableDelegate;

///-----------------------------------
/// @name Managing the selection
///-----------------------------------

/**
 */
@property (nonatomic, readonly) NSInteger selectedIndex;

/**
 */
@property (nonatomic, retain,readonly) NSMutableArray* selectedIndexes;

/**
 */
@property (nonatomic, copy ) CKOptionTableViewControllerSelectionBlock selectionBlock;

/**
 */
@property (nonatomic, assign) BOOL multiSelectionEnabled;


///-----------------------------------
/// @name Managing the apperance
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKTableViewCellStyle optionCellStyle;


@end
