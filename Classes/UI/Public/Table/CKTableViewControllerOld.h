//
//  CKTableViewControllerOld.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "CKCollectionViewControllerOld.h"

/**
 */
typedef NS_ENUM(NSInteger, CKTableViewOrientation) {
	CKTableViewOrientationPortrait,
	CKTableViewOrientationLandscape
} ;

// From UITableViewController:
// Creates a table view with the correct dimensions and autoresizing, setting the datasource and delegate to self.
// In -viewWillAppear:, it reloads the table's data if it's empty. Otherwise, it deselects all rows (with or without animation).
// In -viewDidAppear:, it flashes the table's scroll indicators.
// Implements -setEditing:animated: to toggle the editing state of the table.


/**
 */
@interface CKTableView : UITableView

/**
 */
@property(nonatomic,readonly) BOOL isPreventingUpdates;

/**
 */
- (void)beginPreventingUpdates;

/**
 */
- (void)endPreventingUpdates;

@end

/**
 */
@interface CKTableViewControllerOld : CKCollectionViewControllerOld <UITableViewDataSource, UITableViewDelegate> 

///-----------------------------------
/// @name Initializing a TableView Controller Object
///-----------------------------------

/**
 */
- (id)initWithStyle:(UITableViewStyle)style;

/** Allow to specify the class for the table view that will be created in the controller.
 Sometimes you need to override touches or other stuff by implementing your own tableView class.
 This must inherit CKTableView.
 */
- (Class)tableViewClass;

///-----------------------------------
/// @name Getting the Table View
///-----------------------------------

/**
 */
@property (nonatomic, retain) CKTableView *tableView;

/** tableView is a subview of tableViewContainer. tableViewContainer allow us to rotate the whole content in portrait or landscape correctly.
 */
@property (nonatomic, retain) UIView *tableViewContainer;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic, assign) UITableViewStyle style;

/**
 Specify if the scrolling interactions should be horizontal or vertical
 */
@property (nonatomic, assign) CKTableViewOrientation orientation;

/**
 */
@property (nonatomic, assign) UIEdgeInsets tableViewInsets;


/** Computes the insets that will get applied to the table view and scroll indicators taking care of navigation's controller (navigationBar, toolBar) ans status bar transparency.
 */
@property (nonatomic, readonly) UIEdgeInsets navigationControllerTransparencyInsets;

/**
 */
@property (nonatomic, copy) void(^didAdjustInsetsBlock)(CKTableViewControllerOld* controller);


///-----------------------------------
/// @name Managing Selection
///-----------------------------------

/**
 */
@property (nonatomic, assign, getter = isStickySelection) BOOL stickySelectionEnabled;

/**
 */
- (void)clearSelection:(BOOL)animated;


///-----------------------------------
/// @name Reloading the TableView Controller
///-----------------------------------

/**
 */
- (void)reload;



@end
