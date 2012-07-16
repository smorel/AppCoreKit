//
//  CKManagedTableViewController.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKManagedTableViewController.h"
#import "CKTableViewCellController.h"
#import "CKUIKeyboardInformation.h"
#import "CKNSObject+Bindings.h"
#import "CKStyleManager.h"
#import "CKUIViewController+Style.h"

#pragma mark CKManagedTableSection

@interface CKItemViewContainerController ()
@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@end


@interface CKTableSection ()
@property (nonatomic, assign, readwrite) CKManagedTableViewController* parentController;
@property (nonatomic, assign, readwrite) BOOL collapsed;
@end

@implementation CKTableSection

@synthesize cellControllers = _cellControllers;
@synthesize headerTitle = _headerTitle;
@synthesize footerTitle = _footerTitle;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize canMoveRowsOut = _canMoveRowsOut;
@synthesize canMoveRowsIn = _canMoveRowsIn;
@synthesize collapsed = _collapsed;
@synthesize parentController = _parentController;

- (id)init {
	if (self = [super init]) {
		_cellControllers = [[NSMutableArray array] retain];
		_canMoveRowsIn = YES;
		_canMoveRowsOut = YES;
        _collapsed = NO;
		
	}
	return self;
}

- (void)setCollapsed:(BOOL)bo withRowAnimation:(UITableViewRowAnimation)animation{
    if(_collapsed != bo){
        self.collapsed = bo;
        if(_parentController.state == CKUIViewControllerStateDidAppear){
            NSInteger section = [_parentController indexOfSection:self];
            NSMutableArray* indexPaths = [NSMutableArray array];
            for(int i =0;i<[self.cellControllers count];++i){
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
                [indexPaths addObject:indexPath];
            }
            if(_collapsed){
                [_parentController.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
            }
            else{
                [_parentController.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
            }
        }
    }
}

- (id)initWithCellControllers:(NSArray *)theCellControllers {
	[self init];
	[_cellControllers addObjectsFromArray:theCellControllers];
	return self;
}

- (id)initWithCellControllers:(NSArray *)theCellControllers collapsed:(BOOL)bo{
    [self init];
	[_cellControllers addObjectsFromArray:theCellControllers];
    _collapsed = bo;
	return self;
}

- (void)insertCellController:(CKTableViewCellController *)cellController atIndex:(NSUInteger)index {
	[_cellControllers insertObject:cellController atIndex:index];
}

- (void)removeCellControllerAtIndex:(NSUInteger)index {
	[_cellControllers removeObjectAtIndex:index];
}

- (void)dealloc {
    [self clearBindingsContext];
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
@property (nonatomic, retain) NSString *bindingContextForTableView;
- (void)notifiesCellControllersForVisibleRows;
@end

//

@implementation CKManagedTableViewController

@synthesize managedTableViewDelegate = _managedTableViewDelegate;
@synthesize sections = _sections;
@synthesize pValuesForKeys = _valuesForKeys;
@synthesize orientation = _orientation;
@synthesize resizeOnKeyboardNotification = _resizeOnKeyboardNotification;
@synthesize bindingContextForTableView = _bindingContextForTableView;

- (void)postInit {
	[super postInit];
	self.style = UITableViewStyleGrouped;
	_orientation = CKManagedTableViewOrientationPortrait;
	_resizeOnKeyboardNotification = YES;
    self.bindingContextForTableView = [NSString stringWithFormat:@"ManagedTable_table_<%p>",self];
}

//

- (void)dealloc {
    if(_bindingContextForTableView){
        [NSObject removeAllBindingsForContext:_bindingContextForTableView];
        [_bindingContextForTableView release];
        _bindingContextForTableView = nil;
    }
	[self clear];
	[super dealloc];
}

- (void)updateParams{
	if(self.params == nil){
		self.params = [NSMutableDictionary dictionary];
	}
	
	[self.params setObject:[NSValue valueWithCGSize:self.view.bounds.size] forKey:CKTableViewAttributeBounds];
	[self.params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
	[self.params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
	[self.params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
	[self.params setObject:[NSNumber numberWithDouble:0] forKey:CKTableViewAttributeAnimationDuration];
	[self.params setObject:[NSNumber numberWithBool:NO] forKey:CKTableViewAttributeEditable];
	[self.params setObject:[NSValue valueWithNonretainedObject:self] forKey:CKTableViewAttributeParentController];
}

#pragma mark View Management

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setup];
    
    if(self.tableView.hidden == NO){
        [self performSelector:@selector(notifiesCellControllersForVisibleRows) withObject:nil afterDelay:0.4];
    }
    [NSObject beginBindingsContext:_bindingContextForTableView policy:CKBindingsContextPolicyRemovePreviousBindings];
    [self.tableView bind:@"hidden" target:self action:@selector(tableViewVisibilityChanged:)];
    [NSObject endBindingsContext];
}

-(void)viewWillAppear:(BOOL)animated{
	//[self setup];
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [NSObject removeAllBindingsForContext:_bindingContextForTableView];
    
	[super viewDidUnload];
	// FIXME: Controllers should not be deallocated when the view is unloaded
	[self clear];
}

- (void)tableViewVisibilityChanged:(NSNumber*)hidden{
    if(![hidden boolValue]){
        [self performSelector:@selector(notifiesCellControllersForVisibleRows) withObject:nil afterDelay:0.4];
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	[self notifiesCellControllersForVisibleRows];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	for (CKTableSection *section in self.sections) {
		[section.cellControllers makeObjectsPerformSelector:@selector(viewDidDisappear)];
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
			// Ensure to remove the observer on a controller that was previously observed.
			// Otherwise, removeObserver:forKeyPath: will crash with the message
			//   Cannot remove an observer <WLSettingsViewController 0xX> for the key path 
			//   "value" from <CKStandardCellController 0xX> because it is not registered as 
			//   an observer.'
			if (cellController.key) {
				[cellController removeObserver:self forKeyPath:@"value"];
			}
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
	[self notifiesCellControllersForVisibleRows];
}

#pragma mark Accessors

- (CKTableViewCellController *)cellControllerForIndexPath:(NSIndexPath *)indexPath {
	CKTableSection *section = [self.sections objectAtIndex:indexPath.section];
	CKTableViewCellController *controller = [section.cellControllers objectAtIndex:indexPath.row];
	[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
	return controller;
}

- (void)removeSectionAtIndex:(NSUInteger)sectionIndex {
	[self.sections removeObjectAtIndex:sectionIndex];
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)removeCellControllerAtIndexPath:(NSIndexPath *)indexPath {
	CKTableSection *section = [self.sections objectAtIndex:indexPath.section];
	CKTableViewCellController *cellController = [section.cellControllers objectAtIndex:indexPath.row];
	if (cellController.key) {
		[cellController removeObserver:self forKeyPath:@"value"];
	}
	[section removeCellControllerAtIndex:indexPath.row];
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

// FIXME: The table should watch the section for insertion/deletion instead
- (void)insertCellController:(CKTableViewCellController*)cellController atIndex:(NSUInteger)index inSection:(NSUInteger)sectionIndex animated:(BOOL)animated{
	CKTableSection* section = [_sections objectAtIndex:sectionIndex];
	[section insertCellController:cellController atIndex:index];
	[cellController performSelector:@selector(setParentController:) withObject:self];
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
	[cellController performSelector:@selector(setIndexPath:) withObject:indexPath];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
}


- (void)removeCellControllerAtIndex:(NSUInteger)index inSection:(NSUInteger)sectionIndex animated:(BOOL)animated{
	CKTableSection* section = [_sections objectAtIndex:sectionIndex];
	[section removeCellControllerAtIndex:index];
	
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
	NSArray* rows = [NSArray arrayWithObject:indexPath];
	[self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
}

- (CKTableSection *)sectionAtIndex:(NSUInteger)index {
	return [_sections objectAtIndex:index];
}

#pragma mark UITableView Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)index {
    CKTableSection* section = [self.sections objectAtIndex:index];
	return section.collapsed ? 0 : [[section cellControllers] count];
}

- (NSMutableDictionary*)params{
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	
	[params setObject:[NSValue valueWithCGSize:self.view.bounds.size] forKey:CKTableViewAttributeBounds];
	[params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
	[params setObject:[NSNumber numberWithBool:self.tableView.pagingEnabled] forKey:CKTableViewAttributePagingEnabled];
	[params setObject:[NSNumber numberWithInt:self.orientation] forKey:CKTableViewAttributeOrientation];
	[params setObject:[NSNumber numberWithDouble:0] forKey:CKTableViewAttributeAnimationDuration];
	[params setObject:[NSNumber numberWithBool:NO] forKey:CKTableViewAttributeEditable];
	[params setObject:[NSValue valueWithNonretainedObject:self] forKey:CKTableViewAttributeParentController];
    
    return params;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKTableViewCellController *cellController = [self cellControllerForIndexPath:indexPath];
    CGFloat height = [cellController heightForRow];
    if (height == 0) {
        cellController.rowHeight = tableView.rowHeight;
        height = tableView.rowHeight;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController *controller = [self cellControllerForIndexPath:indexPath];
	NSString *identifier = controller.identifier;
	
	UITableViewCell *theCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (theCell == nil) {
		theCell = (UITableViewCell*)[controller loadView];
	}
    else{
        CKTableViewCellController* previousController = (CKTableViewCellController*)[_viewsToControllers objectForKey:[NSValue valueWithNonretainedObject:theCell]];
        if(previousController && [previousController view] == theCell){
            [previousController setView:nil];
        }
    }
    
    //Sets the delegate of the cell for layout callbacks
    if([theCell isKindOfClass:[CKUITableViewCell class]]){
        CKUITableViewCell* ckCell = (CKUITableViewCell*)theCell;
        ckCell.delegateRef.object = controller;
    }
	
	//TODO
	//We have to see how to resize the tableView to fit correctly in the right side ...
	//for instance we have to disable the resizing masks on the table view and set its size for the wanted orientation in the nib ...
	UIView *rotatedView	= theCell.contentView;
	if (_orientation == CKManagedTableViewOrientationLandscape) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
	}
    
    
    if(_viewsToControllers == nil){ self.viewsToControllers = [NSMutableDictionary dictionary]; }
    [_viewsToControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:theCell]];
    
    [controller setView:theCell];

	[controller setupView:theCell];	
	return theCell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CKTableViewCellController *controller = [self cellControllerForIndexPath:indexPath];
    if([controller isSelectable]){
        return [controller willSelect];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[[self cellControllerForIndexPath:indexPath] didSelect];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    
    CKTableViewCellController *cellController = [self cellControllerForIndexPath:indexPath];
    if([cellController isRemovable]){
        editingStyle = UITableViewCellEditingStyleDelete;
    }

	return editingStyle;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	CKTableViewCellController *cellController = [self cellControllerForIndexPath:indexPath];

	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (self.managedTableViewDelegate && [self.managedTableViewDelegate respondsToSelector:@selector(tableViewController:cellControllerDidDelete:)])
			[self.managedTableViewDelegate tableViewController:self cellControllerDidDelete:cellController];
		[self removeCellControllerAtIndexPath:indexPath];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];

		CKTableSection *section = [self.sections objectAtIndex:indexPath.section];
		if (section.cellControllers.count == 0) [self removeSectionAtIndex:indexPath.section];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    CKTableViewCellController *cellController = [self cellControllerForIndexPath:indexPath];
    return [cellController isEditable];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    CKTableViewCellController *cellController = [self cellControllerForIndexPath:indexPath];
	return [cellController isMovable];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	// Test if the row can move from the source to the proposed section
	if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
		CKTableSection *sourceSection = [self.sections objectAtIndex:sourceIndexPath.section];
		CKTableSection *proposedSection = [self.sections objectAtIndex:proposedDestinationIndexPath.section];
		if ((sourceSection.canMoveRowsOut == NO) || (proposedSection.canMoveRowsIn == NO)) return sourceIndexPath;
	}
    
    if([self tableView:self.tableView canEditRowAtIndexPath:proposedDestinationIndexPath] == NO){
        return sourceIndexPath;
    }
    
	return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self moveCellControllerFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
	if (self.managedTableViewDelegate && [self.managedTableViewDelegate respondsToSelector:@selector(tableViewController:cellControllerDidMoveFromIndexPath:toIndexPath:)])
		[self.managedTableViewDelegate tableViewController:self cellControllerDidMoveFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
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
	return -1; // Not documented by Apple, but returns an automatic height.
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	UIView *footerView = [[self.sections objectAtIndex:section] footerView];
	if (footerView) return footerView.frame.size.height;
	return -1; // Not documented by Apple, but returns an automatic height.
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
	
    
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
        CKTableViewCellController* controller = (CKTableViewCellController*)[self cellControllerForIndexPath:indexPath];
        if(controller.tableViewCell){
            [controller viewDidAppear:controller.tableViewCell];
        }
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

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
	[self notifiesCellControllersForVisibleRows];
}

// Section Management

- (void)addSection:(CKTableSection *)section {
	// Add *self* as a weak reference for all cell controllers
    section.parentController = self;
	[section.cellControllers makeObjectsPerformSelector:@selector(setParentController:) withObject:self];
	[self.sections addObject:section];

	for (CKTableViewCellController *cell in section.cellControllers) {
		if (cell.key) {
			if (cell.value) { [self.pValuesForKeys setObject:cell.value forKey:cell.key]; }
			[cell addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
		}
	}
}

- (CKTableSection *)addSectionWithCellControllers:(NSArray *)cellControllers {
	return [self addSectionWithCellControllers:cellControllers headerTitle:nil footerTitle:nil];
}

- (CKTableSection *)addSectionWithCellControllers:(NSArray *)cellControllers headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle {
	CKTableSection *section = [[[CKTableSection alloc] initWithCellControllers:cellControllers] autorelease];
	section.headerTitle = headerTitle;
	section.footerTitle = footerTitle;
	[self addSection:section];
	return section;
}

#pragma mark Values

- (NSDictionary *)valuesForKeys {
	return self.pValuesForKeys;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	CKTableViewCellController *cellController = (CKTableViewCellController *)object;
	if (cellController.key) {
		[self.pValuesForKeys setObject:cellController.value forKey:cellController.key];
		if (self.managedTableViewDelegate && [self.managedTableViewDelegate respondsToSelector:@selector(tableViewController:cellControllerValueDidChange:)])
			[self.managedTableViewDelegate tableViewController:self cellControllerValueDidChange:cellController];
	}
}

#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
	if (_resizeOnKeyboardNotification == NO) return;
	
	NSDictionary *info = [notification userInfo];
	CGRect keyboardRect = CKUIKeyboardInformationBounds(info);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:CKUIKeyboardInformationAnimationDuration(info)];
	[UIView setAnimationCurve:CKUIKeyboardInformationAnimationCurve(info)];
	CGRect tableViewFrame = self.tableView.frame;
	tableViewFrame.size.height -= keyboardRect.size.height;
	self.tableView.frame = tableViewFrame;
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (_resizeOnKeyboardNotification == NO) return;
	
	NSDictionary *info = [notification userInfo];
	CGRect keyboardRect = CKUIKeyboardInformationBounds(info);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:CKUIKeyboardInformationAnimationDuration(info)];
	[UIView setAnimationCurve:CKUIKeyboardInformationAnimationCurve(info)];
	CGRect tableViewFrame = self.tableView.frame;
	tableViewFrame.size.height += keyboardRect.size.height;
	self.tableView.frame = tableViewFrame;
	[UIView commitAnimations];
}


#pragma mark Orientation Management

- (void)setOrientation:(CKManagedTableViewOrientation)orientation {
	CGRect f = self.tableView.frame;
	CGRect b = self.tableView.bounds;
	
	_orientation = orientation;
	if(orientation == CKManagedTableViewOrientationLandscape) {
		self.tableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
		self.tableView.frame = CGRectMake(f.origin.x,f.origin.y,b.size.width,b.size.height);
	} else {
		self.tableView.transform = CGAffineTransformIdentity;
	}
}

#pragma mark UITableView (CKHeaderViewManagement)

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView*)headerView withTitle:(NSString*)title{
    if([headerView appliedStyle] == nil && [title isKindOfClass:[NSString class]] && [title length] > 0){
        NSMutableDictionary* style = [self controllerStyle];
        [headerView applyStyle:style propertyName:@"sectionHeaderView"];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView*)headerView withTitle:(NSString*)title{
    if([headerView appliedStyle] == nil && [title isKindOfClass:[NSString class]] && [title length] > 0){
        NSMutableDictionary* style = [self controllerStyle];
        [headerView applyStyle:style propertyName:@"sectionFooterView"];
    }
}

- (NSInteger)indexOfSection:(CKTableSection*)section{
    return [_sections indexOfObjectIdenticalTo:section];
}

@end
