//
//  CKTableViewController.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//
//  Initial code created by Jonathan Wight on 2/25/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.

#import <UIKit/UIKit.h>

// From UITableViewController:
// Creates a table view with the correct dimensions and autoresizing, setting the datasource and delegate to self.
// In -viewWillAppear:, it reloads the table's data if it's empty. Otherwise, it deselects all rows (with or without animation).
// In -viewDidAppear:, it flashes the table's scroll indicators.
// Implements -setEditing:animated: to toggle the editing state of the table.

@interface CKTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UIView *_backgroundView;
	UITableView *_tableView;
	UITableViewStyle _style;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) UITableViewStyle style;
@property (nonatomic, retain) UIView *backgroundView;

- (id)initWithStyle:(UITableViewStyle)style;

@end
