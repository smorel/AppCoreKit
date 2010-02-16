//
//  CKTableViewController.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//
//  Initial code created by Jonathan Wight on 2/25/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.

#import "CKTableViewController.h"

@implementation CKTableViewController

@synthesize tableView = _tableView;
@synthesize style = _style;

- (id)init {
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.style = UITableViewStylePlain;
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style { 
	[self init];
	self.style = _style;
	return self;
}

- (void)dealloc {
	self.tableView = nil;
	[super dealloc];
}

#pragma mark Load View

- (void)loadView {
	[super loadView];

	if (self.view == nil) {
		CGRect theViewFrame = [[UIScreen mainScreen] applicationFrame];
		UIView *theView = [[[UITableView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.view = theView;
	}

	if (self.tableView == nil) {
		if ([self.view isKindOfClass:[UITableView class]]) {
			self.tableView = (UITableView *)self.view;
		} else {
			CGRect theViewFrame = self.view.bounds;
			UITableView *theTableView = [[[UITableView alloc] initWithFrame:theViewFrame style:self.style] autorelease];
			theTableView.delegate = self;
			theTableView.dataSource = self;
			theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
			[self.view addSubview:theTableView];
			self.tableView = theTableView;
		}
	}
}

#pragma mark View Management

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)setEditing:(BOOL)inEditing animated:(BOOL)animated {
	[self.tableView setEditing:inEditing animated:animated];
}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end