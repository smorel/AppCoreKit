//
//  CKTableViewController.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//
//  Initial code created by Jonathan Wight on 2/25/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.

#import <Foundation/Foundation.h>
#import "CKItemViewContainerController.h"

@interface CKTableView : UITableView
@property(nonatomic,assign) BOOL sizeChangedWhileReloading;
@property(nonatomic,assign) BOOL isLayouting;
@end

typedef enum {
	CKTableViewOrientationPortrait,
	CKTableViewOrientationLandscape
} CKTableViewOrientation;

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
	CKTableView *_tableView;
	UITableViewStyle _style;
	BOOL _stickySelection;
	NSIndexPath *_selectedIndexPath;
    UIEdgeInsets _tableViewInsets;
}

@property (nonatomic, retain) IBOutlet CKTableView *tableView;
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
