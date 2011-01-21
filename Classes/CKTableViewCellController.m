//
//  CKBasicCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKManagedTableViewController.h"

#import "CKNSArrayAdditions.h"


@implementation CKTableViewCellController

@synthesize key = _key;
@synthesize value = _value;
@synthesize target = _target;
@synthesize action = _action;
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
		self.rowHeight = 44.0f;
		self.editable = YES;
	}
	return self;
}

- (void)dealloc {
	[_key release];
	[_value release];
	[_indexPath release];
	[_target release];
	
	_target = nil;
	_action = nil;
	_parentController = nil;
	[super dealloc];
}

- (NSString *)identifier {
	return [[self class] description];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	// This method is hidden from the public interface and is called by the CKManagedTableViewController
	// when adding the CKTableViewCellController.	
	[_indexPath release];
	_indexPath = [indexPath retain];
}

- (void)setParentController:(CKManagedTableViewController *)parentController {
	// Set a *weak* reference to the parent controller
	// This method is hidden from the public interface and is called by the CKManagedTableViewController
	// when adding the CKTableViewCellController.
	_parentController = parentController;
}

- (UITableViewCell *)tableViewCell {
	return [_parentController.tableView cellForRowAtIndexPath:self.indexPath];
}

#pragma mark Cell Factory

- (UITableViewCell *)cellWithStyle:(UITableViewStyle)style {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:[self identifier]] autorelease];
	
	cell.selectionStyle = self.isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	cell.accessoryType = _accessoryType;
	
	return cell;
}

- (UITableViewCell *)cellWithNibNamed:(NSString *)nibName {
	UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] first];

	cell.selectionStyle = self.isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	
	return cell;
}

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
	if (self.selectable == NO) cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return;
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

// Update

- (void)setNeedsSetup {
	if (self.tableViewCell)
		[self setupCell:self.tableViewCell];
}

@end
