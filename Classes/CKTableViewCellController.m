//
//  CKBasicCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKTableViewCellController+Style.h"
#import "CKTableViewCellController+CKDynamicLayout.h"

#import "CKUILabel+Style.h"
#import "CKBindedTableViewController.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "CKNSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Style.h"
#import "CKLocalization.h"

#import "CKUIView+Positioning.h"
#import "CKProperty.h"
#import "CKNSObject+CKSingleton.h"

//#import <objc/runtime.h>

#define DisclosureImageViewTag  8888991
#define CheckmarkImageViewTag   8888992

@interface CKItemViewController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@end


@interface CKUITableViewCell()
@property (nonatomic,retain) CKWeakRef* delegateRef;
@property (nonatomic,assign,readwrite) CKTableViewCellController* delegate;
@property (nonatomic, retain) NSString* syncControllerViewBindingContextId;
@end

@implementation CKUITableViewCell
@synthesize delegate;
@synthesize delegateRef = _delegateRef;
@synthesize disclosureIndicatorImage = _disclosureIndicatorImage;
@synthesize disclosureButton = _disclosureButton;
@synthesize checkMarkImage = _checkMarkImage;
@synthesize highlightedDisclosureIndicatorImage = _highlightedDisclosureIndicatorImage;
@synthesize highlightedCheckMarkImage = _highlightedCheckMarkImage;
@synthesize syncControllerViewBindingContextId = _syncControllerViewBindingContextId;

//OverLoads sharedInstance here as CKUITableViewCell has to be inited using a style !
+ (id)sharedInstance{
    static CKUITableViewCell* sharedCKUITableViewCell = nil;
    if(!sharedCKUITableViewCell){
        sharedCKUITableViewCell = [[CKUITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sharedCKUITableViewCell"];
    }
    return sharedCKUITableViewCell;
}

- (void)dealloc{
    [NSObject removeAllBindingsForContext:_syncControllerViewBindingContextId];
    [self clearBindingsContext];
    
    [_syncControllerViewBindingContextId release];
    _syncControllerViewBindingContextId = nil;
    [_disclosureIndicatorImage release];
    _disclosureIndicatorImage = nil;
    [_disclosureButton release];
    _disclosureButton = nil;
    [_highlightedDisclosureIndicatorImage release];
    _highlightedDisclosureIndicatorImage = nil;
    [_highlightedCheckMarkImage release];
    _highlightedCheckMarkImage = nil;
    [_delegateRef release];
    _delegateRef = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)thedelegate{
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.delegate = thedelegate;
    self.syncControllerViewBindingContextId = [NSString stringWithFormat:@"syncControllerViewBindingContextId<%p>",self];
	return self;
}

- (id)delegate{
    return self.delegateRef.object;
}

- (void)setDelegate:(CKTableViewCellController *)thedelegate{
	self.delegateRef = [CKWeakRef weakRefWithObject:thedelegate];

    //Keeps controller in sync for size updates if user sets or bind data directly to the cell !
    [NSObject beginBindingsContext:_syncControllerViewBindingContextId options:CKBindingsContextPolicyRemovePreviousBindings];
    [self bind:@"indentationLevel"  toObject:thedelegate withKeyPath:@"indentationLevel"];
    [self.textLabel bind:@"text"  toObject:thedelegate withKeyPath:@"text"];
    [self.detailTextLabel bind:@"text"  toObject:thedelegate withKeyPath:@"detailText"];
    [self.imageView bind:@"image"  toObject:thedelegate withKeyPath:@"image"];
    [self bind:@"accessoryView"  toObject:thedelegate withKeyPath:@"accessoryView"];
    [self bind:@"accessoryType"  toObject:thedelegate withKeyPath:@"accessoryType"];
    [self bind:@"editingAccessoryView"  toObject:thedelegate withKeyPath:@"editingAccessoryView"];
    [self bind:@"editingAccessoryType"  toObject:thedelegate withKeyPath:@"editingAccessoryType"];
    [self bind:@"selectionStyle"  toObject:thedelegate withKeyPath:@"selectionStyle"];
    [NSObject endBindingsContext];	
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
        view.highlightedImage = _highlightedDisclosureIndicatorImage;
        view.tag = DisclosureImageViewTag;
        self.accessoryView = view;
    }
}

- (void)setHighlightedDisclosureIndicatorImage:(UIImage*)image{
    [_highlightedDisclosureIndicatorImage release];
    _highlightedDisclosureIndicatorImage = [image retain];
    if([self.accessoryView tag] == DisclosureImageViewTag){
        UIImageView* view = (UIImageView*)self.accessoryView;
        view.highlightedImage = _highlightedDisclosureIndicatorImage;
    }
}

- (void)setCheckMarkImage:(UIImage*)img{
    [_checkMarkImage release];
    _checkMarkImage = [img retain];
    if(self.accessoryType == UITableViewCellAccessoryCheckmark){
        UIImageView* view = [[[UIImageView alloc]initWithImage:_checkMarkImage]autorelease];
        view.highlightedImage = _highlightedCheckMarkImage;
        view.tag = CheckmarkImageViewTag;
        self.accessoryView = view;
    }
}

- (void)setHighlightedCheckMarkImage:(UIImage*)image{
    [_highlightedCheckMarkImage release];
    _highlightedCheckMarkImage = [image retain];
    if([self.accessoryView tag] == CheckmarkImageViewTag){
        UIImageView* view = (UIImageView*)self.accessoryView;
        view.highlightedImage = _highlightedCheckMarkImage;
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
                view.highlightedImage = _highlightedDisclosureIndicatorImage;
                view.tag = DisclosureImageViewTag;
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
                view.highlightedImage = _highlightedCheckMarkImage;
                view.tag = CheckmarkImageViewTag;
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

@property (nonatomic, assign) CGFloat componentsRatio;
@property (nonatomic, assign) CGFloat componentsSpace;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

- (UITableViewCell *)cellWithStyle:(CKTableViewCellStyle)style;
- (UITableViewCell *)loadCell;

@end

@implementation CKTableViewCellController
@synthesize cellStyle = _cellStyle;
@synthesize componentsRatio = _componentsRatio;
@synthesize componentsSpace = _componentsSpace;
@synthesize cacheLayoutBindingContextId = _cacheLayoutBindingContextId;
@synthesize contentInsets = _contentInsets;
@synthesize indentationLevel = _indentationLevel;
@synthesize text = _text;
@synthesize detailText = _detailText;
@synthesize image = _image;
@synthesize accessoryType = _accessoryType;
@synthesize accessoryView = _accessoryView;
@synthesize editingAccessoryType = _editingAccessoryType;
@synthesize editingAccessoryView = _editingAccessoryView;
@synthesize sizeHasBeenQueriedByTableView = _sizeHasBeenQueriedByTableView;
@synthesize selectionStyle = _selectionStyle;

- (void)postInit {
	[super postInit];
    self.cellStyle = CKTableViewCellStyleDefault;
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        self.componentsRatio = 1.0 / 3.0;
    }
    else{
        self.componentsRatio = 2.0 / 3.0;
    }
    
    self.componentsSpace = 10;
    self.size = CGSizeMake(320,44);
    self.flags = CKItemViewFlagSelectable | CKItemViewFlagEditable;
    self.contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.cacheLayoutBindingContextId = [NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self];
    _indentationLevel = 0;
    _sizeHasBeenQueriedByTableView = NO;
}

- (void)dealloc {
	[NSObject removeAllBindingsForContext:_cacheLayoutBindingContextId];
    
	[self clearBindingsContext];
    [_cacheLayoutBindingContextId release];
	_cacheLayoutBindingContextId = nil;
    
    [_text release];
	_text = nil;
    [_detailText release];
	_detailText = nil;
    [_image release];
	_image = nil;
    [_accessoryView release];
	_accessoryView = nil;
    [_editingAccessoryView release];
	_editingAccessoryView = nil;
	
	[super dealloc];
}

- (void)setCellStyle:(CKTableViewCellStyle)cellStyle{
    _cellStyle = cellStyle;
    [self invalidateSize];//as stylesheet selection could be dependent
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    [super setIndexPath:indexPath];
    [self invalidateSize];//as stylesheet selection could be dependent
}

- (void)setName:(NSString *)name{
    [super setName:name];
    [self invalidateSize];//as stylesheet selection could be dependent
}

- (void)setValue:(id)value{
    [super setValue:value];
    [self invalidateSize];
}

+ (CKTableViewCellController*)cellController{
    return [[[[self class]alloc]init]autorelease];
}

- (void)cellStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKTableViewCellStyle", 
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
		customCell.delegate = self;
	}
}

- (UITableViewCell *)tableViewCell {
	if(self.view){
		NSAssert([self.view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
		return (UITableViewCell*)self.view;
	}
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
	
	return cell;
}

- (NSString *)identifier {
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    if(self.createCallback){
        [self.createCallback execute:self];
        if([controllerStyle containsObjectForKey:CKStyleCellType]){
            self.cellStyle = [controllerStyle cellStyle];
        }
    }
    
	NSString* groupedTableModifier = @"";
	UIView* parentView = [self parentControllerView];
	if([parentView isKindOfClass:[UITableView class]]){
		UITableView* tableView = (UITableView*)parentView;
		if(tableView.style == UITableViewStyleGrouped){
			NSInteger numberOfRows = [(CKItemViewContainerController*)self.containerController numberOfObjectsForSection:self.indexPath.section];
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



- (void)cellDidAppear:(UITableViewCell *)cell {
	return;
}

- (void)cellDidDisappear {
	return;
}

- (void)rotateCell:(UITableViewCell*)cell animated:(BOOL)animated{
}

// Selection

- (NSIndexPath *)willSelectRow {
	return self.indexPath;
}

- (void)didSelectRow {
}


// Update

- (CKTableViewController*)parentTableViewController{
	if([self.containerController isKindOfClass:[CKTableViewController class]]){
		return (CKTableViewController*)self.containerController;
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

- (void)setText:(NSString *)text{
    if(_text == text)
        return;
    
    [_text release];
    _text = [text retain];
    if(self.tableViewCell){
        self.tableViewCell.textLabel.text = text;
    }
    [self invalidateSize];
}

- (void)setDetailText:(NSString *)detailText{
    if(_detailText == detailText)
        return;
    
    [_detailText release];
    _detailText = [detailText retain];
    if(self.tableViewCell){
        self.tableViewCell.detailTextLabel.text = detailText;
    }
    [self invalidateSize];
}

- (void)setImage:(UIImage *)image{
    if(_image == image)
        return;
    
    [_image release];
    _image = [image retain];
    if(self.tableViewCell){
        self.tableViewCell.imageView.image = image;
    }
    [self invalidateSize];
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType{
    if(_accessoryType == accessoryType)
        return;
    
    _accessoryType = accessoryType;
    if(self.tableViewCell){
        self.tableViewCell.accessoryType = accessoryType;
    }
    if(![self.tableViewCell isEditing]){
        [self invalidateSize];
    }
}

- (void)setAccessoryView:(UIView *)accessoryView{
    if(_accessoryView == accessoryView)
        return;
    
    [_accessoryView release];
    _accessoryView = [accessoryView retain];
    if(self.tableViewCell){
        self.tableViewCell.accessoryView = accessoryView;
    }
    if(![self.tableViewCell isEditing]){
        [self invalidateSize];
    }
}

- (void)setEditingAccessoryType:(UITableViewCellAccessoryType)editingAccessoryType{
    if(_editingAccessoryType == editingAccessoryType)
        return;
    
    _editingAccessoryType = editingAccessoryType;
    if(self.tableViewCell){
        self.tableViewCell.editingAccessoryType = editingAccessoryType;
    }
    if([self.tableViewCell isEditing]){
        [self invalidateSize];
    }
}

- (void)setEditingAccessoryView:(UIView *)editingAccessoryView{
    if(_editingAccessoryView == editingAccessoryView)
        return;
    
    [_editingAccessoryView release];
    _editingAccessoryView = [editingAccessoryView retain];
    if(self.tableViewCell){
        self.tableViewCell.editingAccessoryView = editingAccessoryView;
    }
    if([self.tableViewCell isEditing]){
        [self invalidateSize];
    }
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle{
    if(_selectionStyle == selectionStyle)
        return;
    
    _selectionStyle = selectionStyle;
    if(self.tableViewCell){
        self.tableViewCell.selectionStyle = (self.flags & CKItemViewFlagSelectable) ? selectionStyle : UITableViewCellSelectionStyleNone;
    }
}

- (void)setFlags:(CKItemViewFlags)flags{
    [super setFlags:flags];
    if(self.tableViewCell && ! (flags & CKItemViewFlagSelectable)){
        self.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setupView:(UIView *)view{
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        [NSObject removeAllBindingsForContext:_cacheLayoutBindingContextId];
    }
    
    if(self.layoutCallback == nil){
        __block CKTableViewCellController* bself = self;
        self.layoutCallback = [CKCallback callbackWithBlock:^id(id value) {
            [bself performLayout];
            return (id)nil;
        }];
    }
        
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
    //Setup the tableViewCell using internal values.
    //Those values can then be overloaded by setup block
	NSAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
    
    UITableViewCell* cell = (UITableViewCell*)view;
    cell.indentationLevel = self.indentationLevel;
    cell.selectionStyle = (self.flags & CKItemViewFlagSelectable) ? self.selectionStyle : UITableViewCellSelectionStyleNone;
    if(self.text)cell.textLabel.text = self.text;
    if(self.detailText)cell.detailTextLabel.text = self.detailText;
    if(self.image)cell.imageView.image = self.image;
    if(self.accessoryView)cell.accessoryView = self.accessoryView;
    else cell.accessoryType = self.accessoryType;
    if(self.editingAccessoryView)cell.editingAccessoryView = self.editingAccessoryView;
    else cell.editingAccessoryType = self.editingAccessoryType;
    
	[view beginBindingsContextByRemovingPreviousBindings];
	[self setupCell:cell];
	[super setupView:view];
	[view endBindingsContext];
    
    
    //TODO : Check if necessary as setting values on controller or cell will invalidate the size
    //and as a side effect tell the table to refresh the view with this new size !
    /*
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        [NSObject beginBindingsContext:_cacheLayoutBindingContextId policy:CKBindingsContextPolicyRemovePreviousBindings];
        [cell.detailTextLabel bind:@"text" target:self action:@selector(updateLayout:)];
        [cell.textLabel bind:@"text" target:self action:@selector(updateLayout:)];
        [NSObject endBindingsContext];	
    }
     */
    
    [CATransaction commit];
}

- (void)rotateView:(UIView*)view animated:(BOOL)animated{
	[super rotateView:view animated:animated];
	[self rotateCell:(UITableViewCell*)view animated:animated];
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
	if([self.containerController isKindOfClass:[CKTableViewController class]]){
		CKTableViewController* tableViewController = (CKTableViewController*)self.containerController;
		if (tableViewController.stickySelection == NO){
			[tableViewController.tableView deselectRowAtIndexPath:self.indexPath animated:YES];
		}
	}
	[self didSelectRow];
	[super didSelect];
}

- (void)layoutCell:(UITableViewCell *)cell{
    if(self.layoutCallback){
        [self.layoutCallback execute:self];
    }
}

- (void)scrollToRow{
    NSAssert([self.containerController isKindOfClass:[CKTableViewController class]],@"invalid parent controller class");
    CKTableViewController* tableViewController = (CKTableViewController*)self.containerController;
    [tableViewController.tableView scrollToRowAtIndexPath:self.indexPath 
                                         atScrollPosition:UITableViewScrollPositionNone 
                                                 animated:YES];
}

- (void)scrollToRowAfterDelay:(NSTimeInterval)delay{
    [self performSelector:@selector(scrollToRow) withObject:nil afterDelay:delay];
}

@end