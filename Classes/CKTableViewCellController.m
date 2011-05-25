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

@synthesize accessoryType = _accessoryType;
@synthesize cellStyle = _cellStyle;
@synthesize key = _key;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.cellStyle = UITableViewCellStyleDefault;
	}
	return self;
}

- (void)dealloc {
	[self clearBindingsContext];
	[_key release];
	_key = nil;
	[super dealloc];
}


#pragma mark TableViewCell Setter getter

- (void)setView:(UIView*)view{
	_view = view;
	if([view isKindOfClass:[CKUITableViewCellController class]]){
		CKUITableViewCellController* customCell = (CKUITableViewCellController*)view;
		customCell.delegate = self;
	}
}

- (UITableViewCell *)tableViewCell {
	if(self.view){
		NSAssert([self.view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
		return (UITableViewCell*)self.view;
	}
	else if([self.parentController isKindOfClass:[CKTableViewController class]]){
		CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
		return [tableViewController.tableView cellForRowAtIndexPath:self.indexPath];
	}
	return nil;
}

#pragma mark Cell Factory

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:self.cellStyle];
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	return;
}

- (void)initTableViewCell:(UITableViewCell*)cell{
}

- (UITableViewCell *)cellWithStyle:(UITableViewCellStyle)style {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	UITableViewCellStyle cellStyle = style;
	if([controllerStyle containsObjectForKey:CKStyleCellType])
		cellStyle = [controllerStyle cellStyle];

	CKUITableViewCellController *cell = [[[CKUITableViewCellController alloc] initWithStyle:cellStyle reuseIdentifier:[self identifier] delegate:self] autorelease];
	self.view = cell;
	
	return cell;
}

- (NSString *)identifier {
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

#pragma mark CKManagedTableViewController Protocol

- (void)cellDidAppear:(UITableViewCell *)cell {
	return;
}

- (void)cellDidDisappear {
	return;
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
}

// Selection

- (NSIndexPath *)willSelectRow {
	return self.indexPath;
}

- (void)didSelectRow {
}


// Update

- (void)setNeedsSetup {
	if (self.tableViewCell)
		[self setupCell:self.tableViewCell];
}

//This method is used by CKTableViewCellNextResponder to setup the keyboard and the next responder
+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	return NO;
}

- (void)layoutCell:(UITableViewCell *)cell{
	//You can overload this method if you need to update cell layout when cell is resizing.
	//for example you need to resize an accessory view that is not automatically resized as resizingmask are not applied on it.
}


- (CKTableViewController*)parentTableViewController{
	if([self.parentController isKindOfClass:[CKTableViewController class]]){
		return (CKTableViewController*)self.parentController;
	}
	return nil;
}

- (UITableView*)parentTableView{
	return [[self parentTableViewController] tableView];
}


#pragma mark CKItemViewController Implementation

- (UIView *)loadView{
	UITableViewCell* cell = [self loadCell];
	[self initView:cell];
	[self layoutCell:cell];
	[self applyStyle];
	return cell;
}

- (void)initView:(UIView*)view{
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
	[self initTableViewCell:(UITableViewCell*)view];
	[super initView:view];
}

- (void)setupView:(UIView *)view{
	[super setupView:view];
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
	[self setupCell:(UITableViewCell*)view];
}

- (void)rotateView:(UIView*)view withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateView:view withParams:params animated:animated];
	[self rotateCell:(UITableViewCell*)view withParams:params animated:animated];
}

- (void)viewDidAppear:(UIView *)view{
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
	[self cellDidAppear:(UITableViewCell*)view];
	[super viewDidAppear:view];
}

- (void)viewDidDisappear{
	[self cellDidDisappear];
	[super viewDidDisappear];
}

- (NSIndexPath *)willSelect{
	return [self willSelectRow];
}

- (void)didSelect{
	if([self.parentController isKindOfClass:[CKTableViewController class]]){
		CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
		if (tableViewController.stickySelection == NO){
			[tableViewController.tableView deselectRowAtIndexPath:self.indexPath animated:YES];
		}
	}
	[self didSelectRow];
	[super didSelect];
}

@end
