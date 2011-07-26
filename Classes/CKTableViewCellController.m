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
#import "CKNSObject+Bindings.h"

#ifdef DEBUG 
#import "CKPropertyGridEditorController.h"
#endif

#define ENABLE_DEBUG_GESTURE 1

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

@interface CKTableViewCellController ()
@property (nonatomic, retain) id debugModalController;
@end

@implementation CKTableViewCellController

@synthesize accessoryType = _accessoryType;
@synthesize cellStyle = _cellStyle;
@synthesize key = _key;
@synthesize value3Ratio = _value3Ratio;
@synthesize value3LabelsSpace = _value3LabelsSpace;

#ifdef DEBUG 
@synthesize debugModalController;
#endif

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
	
#ifdef DEBUG 
	[debugModalController release];
	debugModalController = nil;
#endif
	
	[super dealloc];
}


#pragma mark TableViewCell Setter getter

- (void)setView:(UIView*)view{
	[super setView:view];
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
	if(self.cellStyle == CKTableViewCellStyleValue3){
		[NSObject beginBindingsContext:[NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
		[cell.detailTextLabel bind:@"text" target:self action:@selector(updateDetailText:)];
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
	
	CGRect frame = CGRectIntegral(CGRectMake(10 + x, 0, width - 10 , cell.contentView.bounds.size.height));
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
			CGRect textFrame = CGRectMake(10,0,detailFrame.origin.x - 10 - self.value3LabelsSpace,detailFrame.size.height);
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
	
#ifdef DEBUG
	if(ENABLE_DEBUG_GESTURE){
		[cell addGestureRecognizer:[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(debugGesture:)]autorelease]];
	}
#endif
	
	return cell;
}

- (void)initView:(UIView*)view{
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
	[self initTableViewCell:(UITableViewCell*)view];
	[super initView:view];
}

- (void)setupView:(UIView *)view{
	[self beginBindingsContextByRemovingPreviousBindings];
	[super setupView:view];
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
	[self setupCell:(UITableViewCell*)view];
	[self endBindingsContext];
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

#ifdef DEBUG 
- (void)debugGesture:(UILongPressGestureRecognizer *)recognizer{
	if ((recognizer.state == UIGestureRecognizerStatePossible) ||
		(recognizer.state == UIGestureRecognizerStateFailed)
		|| self.debugModalController != nil){
		return;
	}
	
	CKPropertyGridEditorController* editor = [[[CKPropertyGridEditorController alloc]initWithObject:self]autorelease];
	editor.title = [NSString stringWithFormat:@"%@ <%p>",[self class],self];
	UIBarButtonItem* close = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeDebug:)]autorelease];
	editor.leftButton = close;
	UINavigationController* navc = [[[UINavigationController alloc]initWithRootViewController:editor]autorelease];
	navc.modalPresentationStyle = UIModalPresentationPageSheet;
	
	self.debugModalController = editor;
	[self.parentController presentModalViewController:navc animated:YES];
}

- (void)closeDebug:(id)sender{
	[self.debugModalController dismissModalViewControllerAnimated:YES];
	self.debugModalController = nil;
}

#endif
@end



@implementation CKTableViewCellController (DEPRECATED_IN_CLOUDKIT_VERSION_1_5_AND_LATER)
@dynamic rowHeight;
@dynamic movable;
@dynamic editable;
@dynamic removable;

- (CGFloat)heightForRow{
    return _rowHeight;
}

- (CGFloat)rowHeight{
    return _rowHeight;
}

- (void)setRowHeight:(CGFloat)f{
    _rowHeight = f;
    NSAssert([self.parentController isKindOfClass:[CKTableViewController class]],@"invalid parent controller");
    CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
    [[tableViewController tableView]beginUpdates];
    [[tableViewController tableView]endUpdates];
}

- (BOOL)isMovable{
    return _movable;
}

- (void)setMovable:(BOOL)bo{
    _movable = bo;
}

- (BOOL)isEditable{
    return _editable;
}

- (void)setEditable:(BOOL)bo{
    _editable = bo;
}

- (BOOL)isRemovable{
    return _movable;
}

- (void)setRemovable:(BOOL)bo{
    _movable = bo;
}


@end
