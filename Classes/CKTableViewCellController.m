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
#import "CKObjectTableViewController.h"
#import "CKObjectPropertyMetaData.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "CKNSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Style.h"
#import "CKLocalization.h"

#import "CKUIView+Positioning.h"

//#import <objc/runtime.h>

@interface CKItemViewController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@end

@implementation CKUITableViewCell
@synthesize delegate;
@synthesize delegateRef = _delegateRef;
@synthesize disclosureIndicatorImage = _disclosureIndicatorImage;
@synthesize disclosureButton = _disclosureButton;
@synthesize checkMarkImage = _checkMarkImage;

- (void)dealloc{
    [self clearBindingsContext];
    
    [_disclosureIndicatorImage release];
    [_disclosureButton release];
    [_delegateRef release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)thedelegate{
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.delegateRef = [CKWeakRef weakRefWithObject:thedelegate];
	return self;
}

- (id)delegate{
    return self.delegateRef.object;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
    if([self.delegate layoutCallback] != nil && self.delegate && [self.delegate respondsToSelector:@selector(layoutCell:)]){
		[self.delegate performSelector:@selector(layoutCell:) withObject:self];
	}
    
    [CATransaction commit];
}

- (void)setDisclosureIndicatorImage:(UIImage*)img{
    [_disclosureIndicatorImage release];
    _disclosureIndicatorImage = [img retain];
    if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        UIImageView* view = [[[UIImageView alloc]initWithImage:_disclosureIndicatorImage]autorelease];
        self.accessoryView = view;
    }
}

- (void)setCheckMarkImage:(UIImage*)img{
    [_checkMarkImage release];
    _checkMarkImage = [img retain];
    if(self.accessoryType == UITableViewCellAccessoryCheckmark){
        UIImageView* view = [[[UIImageView alloc]initWithImage:_checkMarkImage]autorelease];
        self.accessoryView = view;
    }
}

- (void)setDisclosureButton:(UIButton*)button{
    [_disclosureButton release];
    _disclosureButton = [button retain];
    if(self.accessoryType == UITableViewCellAccessoryDetailDisclosureButton){
        self.accessoryView = _disclosureButton;
    }
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)theAccessoryType{
    bool shouldRemoveAccessoryView = (self.accessoryType != theAccessoryType) && (
          (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator && _disclosureIndicatorImage)
        ||(self.accessoryType == UITableViewCellAccessoryDetailDisclosureButton && _disclosureButton)
        ||(self.accessoryType == UITableViewCellAccessoryCheckmark && _checkMarkImage));
    
    if(shouldRemoveAccessoryView){
        self.accessoryView = nil;
    }
    
    switch (theAccessoryType) {
        case UITableViewCellAccessoryDisclosureIndicator:{
            if(_disclosureIndicatorImage){
                UIImageView* view = [[[UIImageView alloc]initWithImage:_disclosureIndicatorImage]autorelease];
                self.accessoryView = view;
            }
            break;
        }
        case UITableViewCellAccessoryDetailDisclosureButton:{
            if(_disclosureButton){
                self.accessoryView = _disclosureButton;
            }
            break;        }
        case UITableViewCellAccessoryCheckmark:{
            if(_checkMarkImage){
                UIImageView* view = [[[UIImageView alloc]initWithImage:_checkMarkImage]autorelease];
                self.accessoryView = view;
            }
            break;
        }
    }
    
    [super setAccessoryType:theAccessoryType];
}

/* Tests for customizing Delete button and editing control
- (void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
    
    NSMutableDictionary* controllerStyle = [self.delegate controllerStyle];
    NSMutableDictionary* myStyle = [controllerStyle styleForObject:self propertyName:@"tableViewCell"];
    
    switch(state){
        case UITableViewCellStateShowingEditControlMask:{
            for(UIView* view in [self subviews]){
                if([[[view class]description]isEqualToString:@"UITableViewCellEditControl"]){
                    NSMutableDictionary* editControlStyle = [myStyle styleForObject:view propertyName:nil];
                    [[view class] applyStyle:editControlStyle toView:view appliedStack:[NSMutableSet set] delegate:nil];
                }
            }
            break;
        }
        case 3:
        case UITableViewCellStateShowingDeleteConfirmationMask:{
            for(UIView* view in [self subviews]){
                if([[[view class]description]isEqualToString:@"UITableViewCellDeleteConfirmationControl"]){
                    Class type = [view class];
                    while(type){
                        NSLog(@"%@",[type description]);
                        type = class_getSuperclass(type);
                    }
                    
                    NSArray* allProperties = [view allPropertyDescriptors];
                    for(CKClassPropertyDescriptor* desc in allProperties){
                        NSLog(@"%@",desc.name);
                    }
                    
                     for(UIView* subview in [view subviews]){
                         Class type = [subview class];
                         while(type){
                             NSLog(@"%@",[type description]);
                             type = class_getSuperclass(type);
                         }
                         
                         NSArray* allProperties = [subview allPropertyDescriptors];
                         for(CKClassPropertyDescriptor* desc in allProperties){
                             NSLog(@"%@",desc.name);
                         }
                     }
                    
                    
                    NSMutableDictionary* deleteControlStyle = [myStyle styleForObject:view propertyName:nil];
                    [[view class] applyStyle:deleteControlStyle toView:view appliedStack:[NSMutableSet set] delegate:nil];
                }
            }
            break;
        }
    }
}
 */

@end

@interface CKTableViewCellController ()

@property (nonatomic, retain) NSString* cacheLayoutBindingContextId;
@end

@implementation CKTableViewCellController

@synthesize accessoryType = _accessoryType;
@synthesize cellStyle = _cellStyle;
@synthesize key = _key;
@synthesize componentsRatio = _componentsRatio;
@synthesize componentsSpace = _componentsSpace;
@synthesize cacheLayoutBindingContextId = _cacheLayoutBindingContextId;
@synthesize contentInsets = _contentInsets;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.cellStyle = CKTableViewCellStyleDefault;
        
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
        self.contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        self.cacheLayoutBindingContextId = [NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self];
	}
	return self;
}

- (void)dealloc {
	[NSObject removeAllBindingsForContext:_cacheLayoutBindingContextId];
	[self clearBindingsContext];
	[_key release];
	_key = nil;
    [_cacheLayoutBindingContextId release];
	_cacheLayoutBindingContextId = nil;
	
	[super dealloc];
}

- (void)cellStyleMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"CKTableViewCellStyle", 
                                               CKTableViewCellStyleDefault,
                                               UITableViewCellStyleDefault,
                                               CKTableViewCellStyleValue1,
                                               UITableViewCellStyleValue1,
                                               CKTableViewCellStyleValue2,
                                               UITableViewCellStyleValue2,
                                               CKTableViewCellStyleSubtitle,
                                               UITableViewCellStyleSubtitle,
                                               CKTableViewCellStyleValue3,
                                               CKTableViewCellStylePropertyGrid,
                                               CKTableViewCellStyleSubtitle2
                                               );
}


#pragma mark TableViewCell Setter getter

- (void)setView:(UIView*)view{
	[super setView:view];
	if([view isKindOfClass:[CKUITableViewCell class]]){
		CKUITableViewCell* customCell = (CKUITableViewCell*)view;
		customCell.delegateRef.object = self;
	}
}

- (UITableViewCell *)tableViewCell {
	if(self.view){
		NSAssert([self.view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
		return (UITableViewCell*)self.view;
	}
	/*else if([self.parentController isKindOfClass:[CKManagedTableViewController class]]){
		CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
		return [tableViewController.tableView cellForRowAtIndexPath:self.indexPath];
	}*/
	return nil;
}

#pragma mark Cell Factory
- (UITableViewCell *)cellWithStyle:(CKTableViewCellStyle)style {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	CKTableViewCellStyle thecellStyle = style;
	if([controllerStyle containsObjectForKey:CKStyleCellType]){
		thecellStyle = [controllerStyle cellStyle];
    }
    
	self.cellStyle = thecellStyle;
	
    //Redirect cell style to a known style for UITableViewCell initialization
    //The layoutCell method will then adapt the layout to our custom type of cell
	CKTableViewCellStyle toUseCellStyle = thecellStyle;
	if(toUseCellStyle == CKTableViewCellStyleValue3
       ||toUseCellStyle == CKTableViewCellStylePropertyGrid){
		toUseCellStyle = CKTableViewCellStyleValue1;
	}
    else if(toUseCellStyle == CKTableViewCellStyleSubtitle2){
		toUseCellStyle = CKTableViewCellStyleSubtitle;
    }
	CKUITableViewCell *cell = [[[CKUITableViewCell alloc] initWithStyle:(UITableViewCellStyle)toUseCellStyle reuseIdentifier:[self identifier] delegate:self] autorelease];
	//self.view = cell;
    cell.accessoryType = self.accessoryType;
	
	return cell;
}

- (NSString *)identifier {
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    if(_createCallback){
        [_createCallback execute:self];
        if([controllerStyle containsObjectForKey:CKStyleCellType]){
            self.cellStyle = [controllerStyle cellStyle];
        }
    }
    
	NSString* groupedTableModifier = @"";
	UIView* parentView = [self parentControllerView];
	if([parentView isKindOfClass:[UITableView class]]){
		UITableView* tableView = (UITableView*)parentView;
		if(tableView.style == UITableViewStyleGrouped){
			NSInteger numberOfRows = [(CKItemViewContainerController*)self.parentController numberOfObjectsForSection:self.indexPath.section];
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
	
	return [NSString stringWithFormat:@"%@-<%p>-%@-[%@]-<%d>",[[self class] description],controllerStyle,groupedTableModifier,self.name ? self.name : @"", self.cellStyle];
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
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        //Ensure detailTextLabel is created !
        if(cell.detailTextLabel == nil){
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,100,44)];
            object_setInstanceVariable(cell, "_detailTextLabel", (void**)(label));
        }
	}
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	if(self.cellStyle == CKTableViewCellStyleValue3){
		cell.textLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        cell.textLabel.textAlignment = UITextAlignmentRight;
        
        cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
        cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
	}
    else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
        cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
            cell.textLabel.textAlignment = UITextAlignmentLeft;
        }
        else{
            cell.textLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.textAlignment = UITextAlignmentRight;
        }
    }
    else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
}

- (void)updateLayout:(id)value{
    [self.tableViewCell setNeedsLayout];
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

+ (UIView*)responderInView:(UIView*)view{
	return nil;
}

- (void)becomeFirstResponder{
    
}

+ (CGFloat)contentViewWidthInParentController:(CKObjectTableViewController*)controller{
    CGFloat rowWidth = 0;
    UIView* tableViewContainer = [controller tableViewContainer];
    UITableView* tableView = [controller tableView];
    if(tableView.style == UITableViewStylePlain){
        rowWidth = tableViewContainer.frame.size.width;
    }
    else if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        rowWidth = tableViewContainer.frame.size.width - 18;
    }
    else{
        CGFloat tableViewWidth = tableViewContainer.frame.size.width;
        CGFloat offset = -1;
        if(tableViewWidth > 716)offset = 90;
        else if(tableViewWidth > 638) offset = 88 - (((NSInteger)(716 - tableViewWidth) / 13) * 2);
        else if(tableViewWidth > 624) offset = 76;
        else if(tableViewWidth > 545) offset = 74 - (((NSInteger)(624 - tableViewWidth) / 13) * 2);
        else if(tableViewWidth > 400) offset = 62;
        else offset = 20;
        
        rowWidth = tableViewWidth - offset;
    }
    return rowWidth;
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
    UIViewController* parentController = [params parentController];
    NSAssert([parentController isKindOfClass:[CKObjectTableViewController class]],@"invalid parent controller");
    
    CGFloat tableWidth = [params bounds].width;
    CKTableViewCellController* staticController = (CKTableViewCellController*)[params staticController];
    if(staticController.cellStyle == CKTableViewCellStyleValue3
       || staticController.cellStyle == CKTableViewCellStylePropertyGrid
       || staticController.cellStyle == CKTableViewCellStyleSubtitle2){
        CGFloat bottomText = staticController.tableViewCell.textLabel.frame.origin.y + staticController.tableViewCell.textLabel.frame.size.height;
        
        CGFloat bottomDetails = 0;
        if(staticController.tableViewCell.detailTextLabel.text != nil &&
           [staticController.tableViewCell.detailTextLabel.text isKindOfClass:[NSString class]] &&
           [staticController.tableViewCell.detailTextLabel.text length] > 0){
            bottomDetails = staticController.tableViewCell.detailTextLabel.frame.origin.y + staticController.tableViewCell.detailTextLabel.frame.size.height;
        }
        
        CGFloat maxHeight = MAX(44, MAX(bottomText,bottomDetails) + staticController.contentInsets.bottom);
        return [NSValue valueWithCGSize:CGSizeMake(tableWidth,maxHeight)];
    }
    return [NSValue valueWithCGSize:CGSizeMake(tableWidth,44)];
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
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
	UITableViewCell* cell = [self loadCell];
    self.view = cell;
    
	[self initView:cell];
	[self layoutCell:cell];
	[self applyStyle];
    
    [CATransaction commit];
	
	return cell;
}

- (void)initView:(UIView*)view{
    [NSObject removeAllBindingsForContext:_cacheLayoutBindingContextId];
    
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
	[self initTableViewCell:(UITableViewCell*)view];
	[super initView:view];
}

- (void)setupView:(UIView *)view{
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        [NSObject removeAllBindingsForContext:_cacheLayoutBindingContextId];
    }
    
    if(_layoutCallback == nil){
        self.layoutCallback = [CKCallback callbackWithTarget:self action:@selector(performStandardLayout:)];
    }
        
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
    
	[self beginBindingsContextByRemovingPreviousBindings];
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
	[self setupCell:(UITableViewCell*)view];
	[super setupView:view];
	[self endBindingsContext];
    
    UITableViewCell* cell = (UITableViewCell*)view;
    
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        [NSObject beginBindingsContext:_cacheLayoutBindingContextId policy:CKBindingsContextPolicyRemovePreviousBindings];
        [cell.detailTextLabel bind:@"text" target:self action:@selector(updateLayout:)];
        [cell.textLabel bind:@"text" target:self action:@selector(updateLayout:)];
        [NSObject endBindingsContext];	
    }
    
    [CATransaction commit];
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

- (void)setLayoutCallback:(CKCallback *)thelayoutCallback{
    [_layoutCallback release];
    _layoutCallback = [thelayoutCallback retain];
}

- (void)layoutCell:(UITableViewCell *)cell{
    if(_layoutCallback){
        [_layoutCallback execute:self];
    }
}

- (void)scrollToRow{
    NSAssert([self.parentController isKindOfClass:[CKTableViewController class]],@"invalid parent controller class");
    CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
    [tableViewController.tableView scrollToRowAtIndexPath:self.indexPath 
                                         atScrollPosition:UITableViewScrollPositionNone 
                                                 animated:YES];
}

- (void)scrollToRowAfterDelay:(NSTimeInterval)delay{
    [self performSelector:@selector(scrollToRow) withObject:nil afterDelay:delay];
}

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



@implementation CKTableViewCellController (CKLayout)


//Value3 layout 
- (CGRect)value3DetailFrameForCell:(UITableViewCell*)cell{
    CGRect textFrame = [self value3TextFrameForCell:cell];
    
    CGFloat rowWidth = [CKTableViewCellController contentViewWidthInParentController:(CKObjectTableViewController*)[self parentController]];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    CGSize size = [cell.detailTextLabel.text  sizeWithFont:cell.detailTextLabel.font 
                                         constrainedToSize:CGSizeMake( width , CGFLOAT_MAX) 
                                             lineBreakMode:cell.detailTextLabel.lineBreakMode];
	
    BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    CGFloat y = isIphone ? ((cell.contentView.frame.size.height / 2.0) - (MAX(cell.detailTextLabel.font.lineHeight,size.height) / 2.0)) : self.contentInsets.top;
	return CGRectIntegral(CGRectMake((textFrame.origin.x + textFrame.size.width) + self.componentsSpace, y, 
                                     MIN(size.width,width) , MAX(textFrame.size.height,MAX(cell.detailTextLabel.font.lineHeight,size.height))));
}

- (CGRect)value3TextFrameForCell:(UITableViewCell*)cell{
    if(cell.textLabel.text == nil || 
       [cell.textLabel.text isKindOfClass:[NSNull class]] ||
       [cell.textLabel.text length] <= 0){
        return CGRectMake(0,0,0,0);
    }
    
    CGFloat rowWidth = [CKTableViewCellController contentViewWidthInParentController:(CKObjectTableViewController*)[self parentController]];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    //Detail Check
    CGSize detailsize = [cell.detailTextLabel.text  sizeWithFont:cell.detailTextLabel.font 
                                         constrainedToSize:CGSizeMake( width , CGFLOAT_MAX) 
                                             lineBreakMode:cell.detailTextLabel.lineBreakMode];
    BOOL detailOn1Line = (detailsize.height == cell.detailTextLabel.font.lineHeight);
    
    
    
    CGFloat maxWidth = realWidth - width - self.componentsSpace;
    
    CGSize size = [cell.textLabel.text  sizeWithFont:cell.textLabel.font 
                                   constrainedToSize:CGSizeMake( maxWidth , CGFLOAT_MAX) 
                                       lineBreakMode:cell.textLabel.lineBreakMode];
    BOOL textOn1Line = (size.height == cell.textLabel.font.lineHeight);
    
    if(detailOn1Line && textOn1Line){
        size.height = MAX(cell.textLabel.font.lineHeight,cell.detailTextLabel.font.lineHeight);
    }
    
    BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    CGFloat y = isIphone ? ((cell.contentView.frame.size.height / 2.0) - (MAX(cell.textLabel.font.lineHeight,size.height) / 2.0)) : self.contentInsets.top;
    if(cell.textLabel.textAlignment == UITextAlignmentRight){
        return CGRectIntegral(CGRectMake(self.contentInsets.left + maxWidth - size.width,y,size.width,MAX(cell.textLabel.font.lineHeight,size.height)));
    }
    else if(cell.textLabel.textAlignment == UITextAlignmentLeft){
        return CGRectIntegral(CGRectMake(self.contentInsets.left,y,size.width,MAX(cell.textLabel.font.lineHeight,size.height)));
    }
    
    //else Center
    return CGRectIntegral(CGRectMake(self.contentInsets.left + (maxWidth - size.width) / 2.0,y,size.width,MAX(cell.textLabel.font.lineHeight,size.height)));
}

//PropertyGrid layout
- (CGRect)propertyGridDetailFrameForCell:(UITableViewCell*)cell{
    //TODO : factoriser un peu mieux ce code la ....
    CGRect textFrame = [self propertyGridTextFrameForCell:cell];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(cell.textLabel.text == nil || 
           [cell.textLabel.text isKindOfClass:[NSNull class]] ||
           [cell.textLabel.text length] <= 0){
            if(cell.detailTextLabel.text != nil && 
               [cell.detailTextLabel.text isKindOfClass:[NSNull class]] == NO &&
               [cell.detailTextLabel.text length] > 0 &&
               cell.detailTextLabel.numberOfLines != 1){
                
                CGFloat realWidth = cell.contentView.frame.size.width;
                CGFloat maxWidth = realWidth - (self.contentInsets.left + self.contentInsets.right);
                
                CGSize size = [cell.detailTextLabel.text  sizeWithFont:cell.detailTextLabel.font 
                                                     constrainedToSize:CGSizeMake( maxWidth , CGFLOAT_MAX) 
                                                         lineBreakMode:cell.detailTextLabel.lineBreakMode];
                return CGRectMake(self.contentInsets.left,self.contentInsets.top, cell.contentView.frame.size.width - (self.contentInsets.left + self.contentInsets.right), size.height);
            }
            else{
                return CGRectMake(self.contentInsets.left,self.contentInsets.top, cell.contentView.frame.size.width - (self.contentInsets.left + self.contentInsets.right), MAX(cell.textLabel.font.lineHeight,textFrame.size.height));
            }
        }
        else{
            //CGRect textFrame = [self propertyGridTextFrameForCell:cell];
            CGFloat x = textFrame.origin.x + textFrame.size.width + self.componentsSpace;
            CGFloat width = cell.contentView.frame.size.width - self.contentInsets.right - x;
            if(width > 0 ){
                if(cell.detailTextLabel.text != nil && 
                   [cell.detailTextLabel.text isKindOfClass:[NSNull class]] == NO &&
                   [cell.detailTextLabel.text length] > 0 &&
                   cell.detailTextLabel.numberOfLines != 1){
                    /*CGSize size = [cell.detailTextLabel.text  sizeWithFont:cell.detailTextLabel.font 
                                                         constrainedToSize:CGSizeMake( width , CGFLOAT_MAX) 
                                                             lineBreakMode:cell.detailTextLabel.lineBreakMode];*/
                    return CGRectMake(x,self.contentInsets.top, width, MAX(cell.textLabel.font.lineHeight,textFrame.size.height));
                }
                else{
                    return CGRectMake(x,self.contentInsets.top, width, MAX(cell.textLabel.font.lineHeight,textFrame.size.height));
                }
            }
            else{
                return CGRectMake(0,0,0,0);
            }
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
            CGFloat rowWidth = [CKTableViewCellController contentViewWidthInParentController:(CKObjectTableViewController*)[self parentController]];
            CGFloat realWidth = rowWidth;
            CGFloat width = realWidth * self.componentsRatio;
            
            CGFloat maxWidth = realWidth - width - self.contentInsets.left - self.componentsSpace;
            CGSize size = [cell.textLabel.text  sizeWithFont:cell.textLabel.font 
                                           constrainedToSize:CGSizeMake( maxWidth , CGFLOAT_MAX) 
                                               lineBreakMode:cell.textLabel.lineBreakMode];
            // NSLog(@"propertyGridTextFrameForCell for cell at index: %@",self.indexPath);
            //NSLog(@"cell width : %f",realWidth);
            //NSLog(@"textLabel size %f %f",size.width,size.height);
            return CGRectMake(self.contentInsets.left,self.contentInsets.top, size.width, size.height);
        }
    }
    return [self value3TextFrameForCell:cell];
}

- (CGRect)subtitleTextFrameForCell:(UITableViewCell*)cell{
    if(cell.textLabel.text == nil || 
       [cell.textLabel.text isKindOfClass:[NSNull class]] ||
       [cell.textLabel.text length] <= 0){
        return CGRectMake(0,0,0,0);
    }
    
    CGFloat x = cell.imageView.x + cell.imageView.width + 10;
    CGFloat width = cell.contentView.width - x - 10;
    
    CGSize size = [cell.textLabel.text  sizeWithFont:cell.textLabel.font 
                                   constrainedToSize:CGSizeMake( width , CGFLOAT_MAX) 
                                       lineBreakMode:cell.textLabel.lineBreakMode];
    
    return CGRectMake(x,11, size.width, size.height);
}


- (CGRect)subtitleDetailFrameForCell:(UITableViewCell*)cell{
    CGRect textFrame = [self subtitleTextFrameForCell:cell];
    CGFloat x = cell.imageView.x + cell.imageView.width + 10;
    CGFloat width = cell.contentView.width - x - 10;
    
    if(cell.detailTextLabel.text == nil || 
       [cell.detailTextLabel.text isKindOfClass:[NSNull class]] ||
       [cell.detailTextLabel.text length] <= 0){
        return CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10,width,0);
    }
    
    CGSize size = [cell.detailTextLabel.text  sizeWithFont:cell.detailTextLabel.font 
                                   constrainedToSize:CGSizeMake( width , CGFLOAT_MAX) 
                                       lineBreakMode:cell.detailTextLabel.lineBreakMode];
    
    return CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10, width/*size.width*/, size.height);
}

- (id)performStandardLayout:(CKTableViewCellController *)controller{
    UITableViewCell* cell = controller.tableViewCell;
    //You can overload this method if you need to update cell layout when cell is resizing.
	//for example you need to resize an accessory view that is not automatically resized as resizingmask are not applied on it.
	if(self.cellStyle == CKTableViewCellStyleValue3){
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
        
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self value3DetailFrameForCell:cell];
		}
		if(cell.textLabel != nil){
			CGRect textFrame = [self value3TextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
		}
	}
    else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self propertyGridDetailFrameForCell:cell];
		}
		if(cell.textLabel != nil){
			CGRect textFrame = [self propertyGridTextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
		}
	}
    else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
        cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
        cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
		if(cell.textLabel != nil){
			CGRect textFrame = [self subtitleTextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
		}
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self subtitleDetailFrameForCell:cell];
		}
	}
    return (id)nil;
}

@end