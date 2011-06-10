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
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import <CloudKit/CKNSObject+Bindings.h>

@interface CKUITableViewCellController : UITableViewCell{
	CKTableViewCellController* _delegate;
}
@property(nonatomic,assign) CKTableViewCellController* delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)delegate;
@end

@implementation CKUITableViewCellController
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)thedelegate{
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.delegate = thedelegate;
	return self;
}

- (void)layoutSubviews{
	[super layoutSubviews];
	
	if(_delegate && [_delegate respondsToSelector:@selector(layoutCell:)]){
		[_delegate performSelector:@selector(layoutCell:) withObject:self];
	}
}

@end

@implementation CKTableViewCellController

@synthesize accessoryType = _accessoryType;
@synthesize cellStyle = _cellStyle;
@synthesize key = _key;
@synthesize value3Ratio = _value3Ratio;
@synthesize value3LabelsSpace = _value3LabelsSpace;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.cellStyle = UITableViewCellStyleDefault;
		self.value3Ratio = 2.0 / 3.0;
		self.value3LabelsSpace = 10;
	}
	return self;
}

- (void)dealloc {
	[self clearBindingsContext];
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self]];
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

//ZEROWINGREF informal protocol
- (void)willOverrideClass{
	[NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self]];
}

//ZEROWINGREF informal protocol
- (void)didOverrideClass{
	if(self.cellStyle == CKTableViewCellStyleValue3){
		[NSObject beginBindingsContext:[NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
		[self.tableViewCell bind:@"detailTextLabel.text" target:self action:@selector(updateDetailText:)];
		[NSObject endBindingsContext];	
	}
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	if(self.cellStyle == CKTableViewCellStyleValue3){
		[NSObject beginBindingsContext:[NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
		[cell bind:@"detailTextLabel.text" target:self action:@selector(updateDetailText:)];
		[NSObject endBindingsContext];	
	}
	
	if(self.cellStyle == CKTableViewCellStyleValue3){
		cell.textLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
}

- (void)updateDetailText:(id)value{
	[self layoutCell:self.tableViewCell];
}

- (UITableViewCell *)cellWithStyle:(CKTableViewCellStyle)style {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	CKTableViewCellStyle thecellStyle = style;
	if([controllerStyle containsObjectForKey:CKStyleCellType])
		thecellStyle = [controllerStyle cellStyle];

	self.cellStyle = thecellStyle;
	
	CKTableViewCellStyle toUseCellStyle = thecellStyle;
	if(toUseCellStyle == CKTableViewCellStyleValue3){
		toUseCellStyle = CKTableViewCellStyleValue1;
	}
	CKUITableViewCellController *cell = [[[CKUITableViewCellController alloc] initWithStyle:toUseCellStyle reuseIdentifier:[self identifier] delegate:self] autorelease];
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

+ (UIResponder*)responderInView:(UIView*)view{
	return nil;
}


- (CGRect)value3FrameForCell:(UITableViewCell*)cell{
	CGFloat realWidth = cell.bounds.size.width;
	CGFloat width = realWidth * self.value3Ratio;
	CGFloat x = realWidth - width;
	
	CGFloat contentWidth = cell.contentView.bounds.size.width;
	width = contentWidth - x;
	
	CGRect frame = CGRectIntegral(CGRectMake(x, 0, width , cell.contentView.bounds.size.height));
	return frame;
}

- (void)layoutCell:(UITableViewCell *)cell{
	//You can overload this method if you need to update cell layout when cell is resizing.
	//for example you need to resize an accessory view that is not automatically resized as resizingmask are not applied on it.
	if(self.cellStyle == CKTableViewCellStyleValue3){
		CGRect detailFrame = [self value3FrameForCell:cell];
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = detailFrame;
			cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
		}
		if(cell.textLabel != nil){
			CGRect textFrame = CGRectMake(0,0,detailFrame.origin.x - self.value3LabelsSpace,detailFrame.size.height);
			cell.textLabel.frame = textFrame;
			cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
			cell.textLabel.textAlignment = UITextAlignmentRight;
		}
	}
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
