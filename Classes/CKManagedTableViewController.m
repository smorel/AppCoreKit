//
//  CKManagedTableViewController.m
//  Urbanizer
//
//  Created by Olivier Collet on 10-03-02.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKManagedTableViewController.h"
#import "CKTableViewCellController.h"

#pragma mark CKManagedTableSection

@implementation CKTableSection

@synthesize cellControllers = _cellControllers;
@synthesize headerTitle = _headerTitle;
@synthesize footerTitle = _footerTitle;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;

- (id)initWithCellControllers:(NSArray *)theCellControllers {
	if (self = [super init]) {
		_cellControllers = [[NSMutableArray arrayWithArray:theCellControllers] retain];
	}
	return self;
}

- (void)dealloc {
	[_cellControllers release];
	self.headerTitle = nil;
	self.footerTitle = nil;
	self.headerView = nil;
	self.footerView = nil;
	[super dealloc];
}

@end

#pragma mark CKManagedTableViewController

@interface CKManagedTableViewController ()
@property (nonatomic, retain, readwrite) NSMutableArray *sections;
@end

//

@implementation CKManagedTableViewController

@synthesize sections = _sections;

- (void)awakeFromNib {
	self.style = UITableViewStyleGrouped;
}

- (id)init {
    if (self = [super init]) {
		self.style = UITableViewStyleGrouped;
    }
    return self;
}

- (void)dealloc {
	[self clear];
	[super dealloc];
}

#pragma mark View Management

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setup];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[self clear];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	for (CKTableSection *section in self.sections) {
		[section.cellControllers makeObjectsPerformSelector:@selector(cellDidDisappear)];
	}
}

#pragma mark Accessors

- (NSMutableArray *)sections {
	if (_sections == nil) {
		_sections = [[NSMutableArray array] retain];
	}
	return _sections;
}

#pragma mark Setup Management

// Creates/updates cell data. This method should only be invoked directly if
// a "reloadData" needs to be avoided. Otherwise, updateAndReload should be used.

- (void)setup {
	return;
}

// Releases the table group data (it will be recreated when next needed)

- (void)clear {
	self.sections = nil;
}

// Performs all work needed to refresh the data and the associated display

- (void)reload {
	[self clear];
	[self setup];
	[super reload];
}

#pragma mark Accessors

- (CKTableViewCellController *)cellControllerForIndexPath:(NSIndexPath *)indexPath {
	CKTableSection *section = [self.sections objectAtIndex:indexPath.section];
	CKTableViewCellController *controller = [section.cellControllers objectAtIndex:indexPath.row];
	[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
	return controller;
}

#pragma mark UITableView Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[self.sections objectAtIndex:section] cellControllers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController *controller = [self cellControllerForIndexPath:indexPath];
	NSString *identifier = controller.identifier;
	
	UITableViewCell *theCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (theCell == nil) {
		theCell = [controller loadCell];
	}

	[controller setupCell:theCell];	
	
	if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
		[controller cellDidAppear:theCell];
	}

	return theCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self cellControllerForIndexPath:indexPath] heightForRow];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self cellControllerForIndexPath:indexPath] willSelectRow];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[[self cellControllerForIndexPath:indexPath] didSelectRow];
}

#pragma mark UITableView Protocol for Secions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[self.sections objectAtIndex:section] headerTitle];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [[self.sections objectAtIndex:section] footerTitle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[self.sections objectAtIndex:section] headerView];
	if (headerView) return headerView.frame.size.height;
	return (tableView.style == UITableViewStyleGrouped) ? 34.0f : tableView.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	UIView *footerView = [[self.sections objectAtIndex:section] footerView];
	if (footerView) return footerView.frame.size.height;
	return (tableView.style == UITableViewStyleGrouped) ? 34.0f : tableView.sectionFooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [[self.sections objectAtIndex:section] headerView];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[self.sections objectAtIndex:section] footerView];
}

#pragma mark UIScrollView Protocol

- (void)notifiesCellControllersForVisibleRows {
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		[[self cellControllerForIndexPath:indexPath] cellDidAppear:[self.tableView cellForRowAtIndexPath:indexPath]];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self notifiesCellControllersForVisibleRows];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self notifiesCellControllersForVisibleRows];
}

// Section Management

- (void)addSection:(CKTableSection *)section {
	// Add *self* as a weak reference for all cell controllers
	[section.cellControllers makeObjectsPerformSelector:@selector(setParentController:) withObject:self];
	[self.sections addObject:section];
}

- (void)addSectionWithCellControllers:(NSArray *)cellControllers {
	[self addSectionWithCellControllers:cellControllers headerTitle:nil footerTitle:nil];
}

- (void)addSectionWithCellControllers:(NSArray *)cellControllers headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle {
	CKTableSection *section = [[CKTableSection alloc] initWithCellControllers:cellControllers];
	section.headerTitle = headerTitle;
	section.footerTitle = footerTitle;
	[self addSection:section];
}

@end
