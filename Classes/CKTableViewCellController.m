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

@interface CKUITableViewCellController : UITableViewCell{
	id _delegate;
}
@property(nonatomic,assign) id delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegate;
@end

@implementation CKUITableViewCellController
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)thedelegate{
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.delegate = thedelegate;
	return self;
}

- (void)layoutSubviews{
	if(_delegate && [_delegate respondsToSelector:@selector(layoutCell:)]){
		[_delegate performSelector:@selector(layoutCell:) withObject:self];
	}
	[super layoutSubviews];
}

@end

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
@synthesize cellStyle = _cellStyle;

@synthesize initCallback;
@synthesize setupCallback;
@synthesize selectionCallback;
@synthesize accessorySelectionCallback;

- (id)init {
	self = [super init];
	if (self != nil) {
		_selectable = YES;
		self.rowHeight = 0.0f;
		self.editable = YES;
		self.cellStyle = UITableViewCellStyleDefault;
	}
	return self;
}

- (void)dealloc {
	[self clearBindingsContext];
	
	[_key release];
	[_value release];
	[_indexPath release];
	[_target release];
	[_name release];
	
	
	[initCallback release];
	[setupCallback release];
	[selectionCallback release];
	[accessorySelectionCallback release];
	
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
	if([cell isKindOfClass:[CKUITableViewCellController class]]){
		CKUITableViewCellController* customCell = (CKUITableViewCellController*)cell;
		customCell.delegate = self;
	}
}

- (UITableViewCell *)tableViewCell {
	if(_tableViewCell)
		return _tableViewCell;
	return [_parentController.tableView cellForRowAtIndexPath:self.indexPath];
}

#pragma mark Cell Factory


- (void)initTableViewCell:(UITableViewCell*)cell{
}

- (UITableViewCell *)cellWithStyle:(UITableViewCellStyle)style {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	UITableViewCellStyle cellStyle = style;
	if([controllerStyle containsObjectForKey:CKStyleCellType])
		cellStyle = [controllerStyle cellStyle];

	CKUITableViewCellController *cell = [[[CKUITableViewCellController alloc] initWithStyle:cellStyle reuseIdentifier:[self identifier] delegate:self] autorelease];
	self.tableViewCell = cell;
	
	/*UITableViewCellAccessoryType acType = self.accessoryType;
	if([controllerStyle containsObjectForKey:CKStyleAccessoryType])
		acType = [controllerStyle accessoryType];
	
	cell.accessoryType = acType;*/
	
	if(initCallback != nil){
		[initCallback execute:self];
	}
	//cell.selectionStyle = self.isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	[self initTableViewCell:cell];
	[self layoutCell:cell];
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
	UITableViewCell *cell = [self cellWithStyle:self.cellStyle];
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	if(setupCallback != nil){
		[setupCallback execute:self];
	}
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
	//if (self.isSelectable) {
		if (self.parentController.stickySelection == NO) [self.parentController.tableView deselectRowAtIndexPath:self.indexPath animated:YES];
		if (_target && [_target respondsToSelector:_action]) {
			[_target performSelector:_action withObject:self];
		}
	if(selectionCallback != nil){
		[selectionCallback execute:self];
	}
	//}
}


- (void)didSelectAccessoryView{
	if (_target && [_target respondsToSelector:_accessoryAction]) {
		[_target performSelector:_accessoryAction withObject:self];
	}
	if(accessorySelectionCallback != nil){
		[accessorySelectionCallback execute:self];
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

- (void)layoutCell:(UITableViewCell *)cell{
	//You can overload this method if you need to update cell layout when cell is resizing.
	//for example you need to resize an accessory view that is not automatically resized as resizingmask are not applied on it.
}

@end
