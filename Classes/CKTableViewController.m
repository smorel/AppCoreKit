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


@interface CKTableViewController ()
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@end


@implementation CKTableViewController

@synthesize backgroundView = _backgroundView;
@synthesize tableView = _tableView;
@synthesize style = _style;
@synthesize stickySelection = _stickySelection;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize tableViewContainer = _tableViewContainer;

- (void)postInit {
	[super postInit];
	self.style = UITableViewStylePlain;
}

- (id)initWithStyle:(UITableViewStyle)style { 
	self = [super init];
	if (self) {
		[self postInit];
		self.style = style;
	}
	return self;
}

- (void)dealloc {
	self.selectedIndexPath = nil;
	self.backgroundView = nil;
	self.tableView = nil;
	self.tableViewContainer = nil;
	[super dealloc];
}

#pragma mark View Management

- (void)loadView {
	[super loadView];

	if (self.view == nil) {
		CGRect theViewFrame = [[UIScreen mainScreen] applicationFrame];
		UIView *theView = [[[UITableView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.view = theView;
	}
	//self.view.clipsToBounds = YES;
	
	if ([self.view isKindOfClass:[UITableView class]] == NO && self.tableViewContainer == nil) {
		CGRect theViewFrame = self.view.bounds;
		UIView *theView = [[[UIView alloc] initWithFrame:theViewFrame] autorelease];
		theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.tableViewContainer = theView;
		[self.view addSubview:theView];
	}

	if (self.tableView == nil) {
		if ([self.view isKindOfClass:[UITableView class]]) {
			// TODO: Assert - Should not be allowed
			self.tableView = (UITableView *)self.view;
		} else {
			CGRect theViewFrame = self.view.bounds;
			UITableView *theTableView = [[[UITableView alloc] initWithFrame:theViewFrame style:self.style] autorelease];
			theTableView.delegate = self;
			theTableView.dataSource = self;
			theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
			[self.tableViewContainer addSubview:theTableView];
			self.tableView = theTableView;
		}
	}
	
	//self.tableView.clipsToBounds = NO;
}

- (void)viewDidUnload {
	self.tableView = nil;
	self.tableViewContainer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	if (self.stickySelection == NO){
		NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
		if([self isValidIndexPath:indexPath]){
			[self.tableView deselectRowAtIndexPath:indexPath animated:animated];
		}
	}
	else if (self.selectedIndexPath && [self isValidIndexPath:self.selectedIndexPath]){
		[self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (self.stickySelection == NO) [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
	else self.selectedIndexPath = [self.tableView indexPathForSelectedRow];
}

#pragma mark Selection

- (void)clearSelection:(BOOL)animated {
	if (self.selectedIndexPath) [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:animated];
	self.selectedIndexPath = nil;
}

- (void)reload {
	[self.tableView reloadData];
	if (self.stickySelection == YES && [self isValidIndexPath:self.selectedIndexPath]) {
		[self.tableView selectRowAtIndexPath:_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

#pragma mark Setters

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}

- (void)setBackgroundView:(UIView *)backgroundView {
	[_backgroundView removeFromSuperview];
	[_backgroundView release];
	if (backgroundView) {
		_backgroundView = [backgroundView retain];
		[self.view insertSubview:backgroundView belowSubview:self.tableView];
		self.tableView.backgroundColor = [UIColor clearColor];
	}
	else _backgroundView = nil;
}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedIndexPath = indexPath;
}

#pragma mark CKItemViewContainerController Implementation

- (NSArray*)visibleIndexPaths{
	return [self.tableView indexPathsForVisibleRows];
}

- (NSIndexPath*)indexPathForView:(UIView*)view{
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"invalid view type");
	NSIndexPath* indexPath =  [self.tableView indexPathForCell:(UITableViewCell*)view];
    if(!indexPath){
        indexPath = [super indexPathForView:view];
    }
    return indexPath;
}

/* implemented in parent controller now.
- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	return [self.tableView cellForRowAtIndexPath:indexPath];
}
 */

@end