//
//  CKTableViewController.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewContainerController.h"

// From UITableViewController:
// Creates a table view with the correct dimensions and autoresizing, setting the datasource and delegate to self.
// In -viewWillAppear:, it reloads the table's data if it's empty. Otherwise, it deselects all rows (with or without animation).
// In -viewDidAppear:, it flashes the table's scroll indicators.
// Implements -setEditing:animated: to toggle the editing state of the table.


/** TODO
 */
@interface CKTableViewController : CKItemViewContainerController <UITableViewDataSource, UITableViewDelegate> {
	UIView *_backgroundView;
	UIView *_tableViewContainer;
	UITableView *_tableView;
	UITableViewStyle _style;
	BOOL _stickySelection;
	NSIndexPath *_selectedIndexPath;
    UIEdgeInsets _tableViewInsets;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *tableViewContainer;
@property (nonatomic, assign) UITableViewStyle style;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, assign) BOOL stickySelection;
@property (nonatomic, assign) UIEdgeInsets tableViewInsets;

- (id)initWithStyle:(UITableViewStyle)style;
- (void)clearSelection:(BOOL)animated;
- (void)reload;

//this will resize the tableViewContainer and the tableView contentOffset using the view frame and the tableViewInsets
- (void)sizeToFit;

@end
