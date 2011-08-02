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

@interface CKUITableViewCell : UITableViewCell{
	CKTableViewCellController* _delegate;
}
@property(nonatomic,assign) CKTableViewCellController* delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)delegate;
@end

@implementation CKUITableViewCell
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
@synthesize componentsRatio = _componentsRatio;
@synthesize componentsSpace = _componentsSpace;

#ifdef DEBUG 
@synthesize debugModalController;
#endif

- (id)init {
	self = [super init];
	if (self != nil) {
		self.cellStyle = UITableViewCellStyleDefault;
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            self.componentsRatio = 1.0 / 3.0;
        }
        else{
            self.componentsRatio = 2.0 / 3.0;
        }
        
		self.componentsSpace = 10;
        
        self.selectable = YES;
        self.rowHeight = 44.0f;
        self.editable = YES;
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
	if([view isKindOfClass:[CKUITableViewCell class]]){
		CKUITableViewCell* customCell = (CKUITableViewCell*)view;
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
- (UITableViewCell *)cellWithStyle:(CKTableViewCellStyle)style {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	CKTableViewCellStyle thecellStyle = style;
	if([controllerStyle containsObjectForKey:CKStyleCellType])
		thecellStyle = [controllerStyle cellStyle];
    
	self.cellStyle = thecellStyle;
	
    //Redirect cell style to a known style for UITableViewCell initialization
    //The layoutCell method will then adapt the layout to our custom type of cell
	CKTableViewCellStyle toUseCellStyle = thecellStyle;
	if(toUseCellStyle == CKTableViewCellStyleValue3
       ||toUseCellStyle == CKTableViewCellStylePropertyGrid){
		toUseCellStyle = CKTableViewCellStyleValue1;
	}
	CKUITableViewCell *cell = [[[CKUITableViewCell alloc] initWithStyle:toUseCellStyle reuseIdentifier:[self identifier] delegate:self] autorelease];
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

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:self.cellStyle];
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	return;
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid){
		[NSObject beginBindingsContext:[NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
		[cell.detailTextLabel bind:@"text" target:self action:@selector(updateLayout:)];
        [cell.textLabel bind:@"text" target:self action:@selector(updateLayout:)];
		[NSObject endBindingsContext];	
	}
	
	if(self.cellStyle == CKTableViewCellStyleValue3){
		cell.textLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
		cell.detailTextLabel.textColor = [UIColor blackColor];
        
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        cell.textLabel.textAlignment = UITextAlignmentRight;
	}
    else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
            cell.textLabel.textAlignment = UITextAlignmentLeft;
        }
        else{
            cell.textLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.textAlignment = UITextAlignmentRight;
        }
    }
}

- (void)updateLayout:(id)value{
	[self layoutCell:self.tableViewCell];
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

//Value3 layout 
- (CGRect)value3DetailFrameForCell:(UITableViewCell*)cell{
	CGFloat realWidth = cell.bounds.size.width;
	CGFloat width = realWidth * self.componentsRatio;
	CGFloat x = realWidth - width;
	
	CGFloat contentWidth = cell.contentView.bounds.size.width;
	width = contentWidth - x;
	
	return CGRectIntegral(CGRectMake(10 + x, 0, width - 10 , cell.contentView.bounds.size.height));
}

- (CGRect)value3TextFrameForCell:(UITableViewCell*)cell{
    CGRect detailFrame = [self value3DetailFrameForCell:cell];
    return CGRectMake(10,0,detailFrame.origin.x - 10 - self.componentsSpace,detailFrame.size.height);
}

//PropertyGrid layout
- (CGRect)propertyGridDetailFrameForCell:(UITableViewCell*)cell{
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(cell.textLabel.text == nil || 
           [cell.textLabel.text isKindOfClass:[NSNull class]] ||
           [cell.textLabel.text length] <= 0){
            return CGRectMake(10,0, cell.contentView.bounds.size.width - 20, cell.contentView.bounds.size.height);
        }
        else{
            CGRect textFrame = [self propertyGridTextFrameForCell:cell];
            CGFloat x = textFrame.origin.x + textFrame.size.width + self.componentsSpace;
            CGFloat width = cell.contentView.bounds.size.width - 10 - x;
            return CGRectMake(x,0, width, cell.contentView.bounds.size.height);
        }
    }
    return [self value3DetailFrameForCell:cell];
}

- (CGRect)propertyGridTextFrameForCell:(UITableViewCell*)cell{
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(cell.textLabel.text == nil || 
           [cell.textLabel.text isKindOfClass:[NSNull class]] ||
           [cell.textLabel.text length] <= 0){
            return CGRectMake(0,0,0,0);
        }
        else{
            CGFloat realWidth = cell.bounds.size.width;
            CGFloat width = realWidth * self.componentsRatio;
            
            CGSize size = [cell.textLabel.text  sizeWithFont:cell.textLabel.font 
                   constrainedToSize:CGSizeMake( realWidth - width - 10 , cell.contentView.bounds.size.height) 
                                               lineBreakMode:cell.textLabel.lineBreakMode];
            return CGRectMake(10,0, size.width, cell.contentView.bounds.size.height);
        }
    }
    return [self value3TextFrameForCell:cell];
}

- (void)layoutCell:(UITableViewCell *)cell{
	//You can overload this method if you need to update cell layout when cell is resizing.
	//for example you need to resize an accessory view that is not automatically resized as resizingmask are not applied on it.
	if(self.cellStyle == CKTableViewCellStyleValue3){
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self value3DetailFrameForCell:cell];
            cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
		}
		if(cell.textLabel != nil){
			CGRect textFrame = [self value3TextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
			cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
		}
	}
    else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self propertyGridDetailFrameForCell:cell];
            cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
		}
		if(cell.textLabel != nil){
			CGRect textFrame = [self propertyGridTextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
			cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
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
@dynamic selectable;
@dynamic value3Ratio;
@dynamic value3LabelsSpace;

- (CGFloat)heightForRow{
    return _rowHeight;
}

- (void)setRowHeight:(CGFloat)f{
    _rowHeight = f;
    if(self.parentController){
        NSAssert([self.parentController isKindOfClass:[CKTableViewController class]],@"invalid parent controller");
        CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
        [[tableViewController tableView]beginUpdates];
        [[tableViewController tableView]endUpdates];
    }
}

- (CGFloat)value3Ratio{
    return _componentsRatio;
}

- (void)setValue3Ratio:(CGFloat)f{
    _componentsRatio = f;
}

- (CGFloat)value3LabelsSpace{
    return _componentsSpace;
}

- (void)setValue3LabelsSpace:(CGFloat)f{
    _componentsSpace = f;
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

- (BOOL)isSelectable{
    return _selectable;
}

- (void)setSelectable:(BOOL)bo{
    _selectable = bo;
}

@end
