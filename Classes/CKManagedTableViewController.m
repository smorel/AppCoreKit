//
//  CKManagedTableViewController.m
//  CloudKit
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

- (void)insertCellController:(CKTableViewCellController *)cellController atIndex:(NSUInteger)index {
	[_cellControllers insertObject:cellController atIndex:index];
}

- (void)removeCellControllerAtIndex:(NSUInteger)index {
	[_cellControllers removeObjectAtIndex:index];
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
@property (nonatomic, retain) NSMutableDictionary *pValuesForKeys;
- (void)notifiesCellControllersForVisibleRows;
@end

//

@implementation CKManagedTableViewController

@synthesize delegate = _delegate;
@synthesize sections = _sections;
@synthesize pValuesForKeys = _valuesForKeys;

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
	// FIXME: Controllers should not be deallocated when the view is unloaded
	[self clear];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self notifiesCellControllersForVisibleRows];
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

- (NSMutableDictionary *)pValuesForKeys {
	if (_valuesForKeys == nil) {
		_valuesForKeys = [[NSMutableDictionary dictionary] retain];
	}
	return _valuesForKeys;
}

#pragma mark Setup Management

// Creates/updates cell data. This method should only be invoked directly if
// a "reloadData" needs to be avoided. Otherwise, updateAndReload should be used.

- (void)setup {
	return;
}

// Releases the table group data (it will be recreated when next needed)

- (void)clear {
	for (CKTableSection *section in self.sections) {
		for (CKTableViewCellController *cellController in section.cellControllers) {
			[cellController removeObserver:self forKeyPath:@"value"];
		}
	}
	self.sections = nil;
	self.pValuesForKeys = nil;
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

- (void)removeCellControllerAtIndexPath:(NSIndexPath *)indexPath {
	CKTableSection *section = [self.sections objectAtIndex:indexPath.section];
	CKTableViewCellController *cellController = [section.cellControllers objectAtIndex:indexPath.row];
	[cellController removeObserver:self forKeyPath:@"value"];
	[section removeCellControllerAtIndex:indexPath.row];
	
	if (section.cellControllers.count == 0) [self.sections removeObjectAtIndex:indexPath.section];
}

- (void)moveCellControllerFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	CKTableViewCellController *cellController = [[self cellControllerForIndexPath:fromIndexPath] retain];
	[cellController performSelector:@selector(setIndexPath:) withObject:toIndexPath];

	CKTableSection *fromSection = [self.sections objectAtIndex:fromIndexPath.section];
	CKTableSection *toSection = [self.sections objectAtIndex:toIndexPath.section];
	[fromSection removeCellControllerAtIndex:fromIndexPath.row];
	[toSection insertCellController:cellController atIndex:toIndexPath.row];
	[cellController release];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
	if ([self cellControllerForIndexPath:indexPath].isRemovable) editingStyle = UITableViewCellEditingStyleDelete;
	return editingStyle;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController *cellController = [self cellControllerForIndexPath:indexPath];

	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self removeCellControllerAtIndexPath:indexPath];
		if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewController:cellControllerDidDelete:)])
			[self.delegate tableViewController:self cellControllerDidDelete:cellController];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}	
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self cellControllerForIndexPath:indexPath].isMovable;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self moveCellControllerFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
	if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewController:cellControllerDidMoveFromIndexPath:toIndexPath:)])
		[self.delegate tableViewController:self cellControllerDidMoveFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}


#pragma mark UITableView Protocol for Sections

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
	// NOTE: We don't use [self.tableView indexPathsForVisibleRows] because it returns nil
	// the first time the view appears. However, [self.tableView visibleCells] correctly returns
	// the cells; maybe it's because it "loads" the cell, or maybe there is a bug in the framework.
	// The documentation doesn't say anything about this.	
	
	NSArray *visibleCells = [self.tableView visibleCells];
	
	for (UITableViewCell *cell in visibleCells) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		NSLog(@"%d", indexPath.row);
		[[self cellControllerForIndexPath:indexPath] cellDidAppear:[self.tableView cellForRowAtIndexPath:indexPath]];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate || scrollView.decelerating)
		return;
	[self notifiesCellControllersForVisibleRows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self notifiesCellControllersForVisibleRows];
}

// Section Management

- (void)addSection:(CKTableSection *)section {
	// Add *self* as a weak reference for all cell controllers
	[section.cellControllers makeObjectsPerformSelector:@selector(setParentController:) withObject:self];
	[self.sections addObject:section];

	for (CKTableViewCellController *cell in section.cellControllers) {
		[cell addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
	}
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

#pragma mark Values

- (NSDictionary *)valuesForKeys {
	return self.pValuesForKeys;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	CKTableViewCellController *cellController = (CKTableViewCellController *)object;
	if (cellController.key) {
		[self.pValuesForKeys setObject:cellController.value forKey:cellController.key];
		if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewController:cellControllerValueDidChange:)])
			[self.delegate tableViewController:self cellControllerValueDidChange:cellController];
	}
}

@end
