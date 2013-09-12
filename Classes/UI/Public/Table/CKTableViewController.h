//
//  CKTableViewController.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "CKCollectionViewController.h"

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
@end

/**
 */
@interface CKTableViewController : CKCollectionViewController <UITableViewDataSource, UITableViewDelegate> 

///-----------------------------------
/// @name Initializing a TableView Controller Object
///-----------------------------------

/**
 */
- (id)initWithStyle:(UITableViewStyle)style;

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
 */
@property (nonatomic, assign) UIEdgeInsets tableViewInsets;


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
