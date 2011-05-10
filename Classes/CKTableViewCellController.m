//
//  CKBasicCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKManagedTableViewController.h"
#import "CKTableViewCellController+Style.h"

#import "CKStyleManager.h"
#import <CloudKit/CKNSObject+Bindings.h>

@implementation CKTableViewCellController

@synthesize name = _name;
@synthesize key = _key;
@synthesize value = _value;
@synthesize target = _target;
@synthesize action = _action;
@synthesize accessoryAction = _accessoryAction;
@synthesize selectable = _selectable;
@synthesize editable = _editable;
@synthesize removable = _removable;
@synthesize movable = _movable;
@synthesize accessoryType = _accessoryType;
@synthesize parentController = _parentController;
@synthesize indexPath = _indexPath;
@synthesize rowHeight = _rowHeight;

- (id)init {
	self = [super init];
	if (self != nil) {
		_selectable = YES;
		self.rowHeight = 0.0f;
		self.editable = YES;
	}
	return self;
}

- (void)dealloc {
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	
	[_key release];
	[_value release];
	[_indexPath release];
	[_target release];
	[_name release];
	
	_target = nil;
	_action = nil;
	_parentController = nil;
	[super dealloc];
}

- (NSString *)identifier {
	//Different identifier for rows that begins or end a section in grouped tables
	NSString* groupedTableModifier = @"";
	UIView* parentView = [self parentControllerView];
	if([parentView isKindOfClass:[UITableView class]]){
		UITableView* tableView = (UITableView*)parentView;
		if(tableView.style == UITableViewStyleGrouped){
			NSInteger numberOfRows = [tableView numberOfRowsInSection:self.indexPath.section];
			if(self.indexPath.row == 0 && numberOfRows > 1){
				groupedTableModifier = @"BeginGroup";
			}
			else if(self.indexPath.row == 0){
				groupedTableModifier = @"AloneInGroup";
			}
			else if(self.indexPath.row == numberOfRows-1){
				groupedTableModifier = @"EndingGroup";
			}
		}
	}
	
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	return [NSString stringWithFormat:@"%@-<%p>-%@",[[self class] description],controllerStyle,groupedTableModifier];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	// This method is hidden from the public interface and is called by the CKManagedTableViewController
	// when adding the CKTableViewCellController.	
	[_indexPath release];
	_indexPath = [indexPath retain];
}

- (void)setParentController:(CKTableViewController *)parentController {
	// Set a *weak* reference to the parent controller
	// This method is hidden from the public interface and is called by the CKManagedTableViewController
	// when adding the CKTableViewCellController.
	_parentController = parentController;
}

- (void)setTableViewCell:(UITableViewCell*)cell{
	_tableViewCell = cell;
}

- (UITableViewCell *)tableViewCell {
	if(_tableViewCell)
		return _tableViewCell;
	return [_parentController.tableView cellForRowAtIndexPath:self.indexPath];
}

#pragma mark Cell Factory


- (void)initTableViewCell:(UITableViewCell*)cell{
}

- (UITableViewCell *)cellWithStyle:(UITableViewStyle)style {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	UITableViewStyle cellStyle = style;
	if([controllerStyle containsObjectForKey:CKStyleCellType])
		cellStyle = [controllerStyle cellStyle];

	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:[self identifier]] autorelease];
	self.tableViewCell = cell;
	
	UITableViewCellAccessoryType acType = self.accessoryType;
	if([controllerStyle containsObjectForKey:CKStyleAccessoryType])
		acType = [controllerStyle accessoryType];
	
	cell.accessoryType = acType;
	//cell.selectionStyle = self.isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	[self initTableViewCell:cell];
	
	[self applyStyle:controllerStyle forCell:cell];
	
	return cell;
}

/*
- (UITableViewCell *)cellWithNibNamed:(NSString *)nibName {
	UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] first];

	cell.selectionStyle = self.isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	
	return cell;
}
 */

#pragma mark CKManagedTableViewController Protocol

- (void)cellDidAppear:(UITableViewCell *)cell {
	return;
}

- (void)cellDidDisappear {
	return;
}

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:UITableViewCellStyleDefault];
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	//if (self.selectable == NO) cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return;
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
}

- (CGFloat)heightForRow {
	return self.rowHeight;
}

// Selection

- (NSIndexPath *)willSelectRow {
	return self.isSelectable ? self.indexPath : nil;
}

- (void)didSelectRow {
	if (self.isSelectable) {
		if (self.parentController.stickySelection == NO) [self.parentController.tableView deselectRowAtIndexPath:self.indexPath animated:YES];
		if (_target && [_target respondsToSelector:_action]) {
			[_target performSelector:_action withObject:self];
		}
	}
}


- (void)didSelectAccessoryView{
	if (_target && [_target respondsToSelector:_accessoryAction]) {
		[_target performSelector:_accessoryAction withObject:self];
	}
}

// Update

- (void)setNeedsSetup {
	if (self.tableViewCell)
		[self setupCell:self.tableViewCell];
}

+ (CKTableViewCellFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKTableViewCellFlagAll;
}


+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	return NO;
}

@end
