//
//  CKTableViewCellController.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKTableViewCellController+Style.h"
#import "UIView+Style.h"
#import "CKTableViewCellController+DynamicLayout.h"
#import "CKTableViewCellController+DynamicLayout_Private.h"

#import "UILabel+Style.h"
#import "CKTableCollectionViewController.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import "CKTableViewCellController+FlatHierarchy.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "NSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Style.h"
#import "CKLocalization.h"
#import "CKRuntime.h"

#import "UIView+Positioning.h"
#import "CKProperty.h"
#import "NSObject+Singleton.h"
#import "CKDebug.h"
#import "UIView+Name.h"
#import "CKConfiguration.h"
#import "Layout.h"
#import "CKStyle+Parsing.h"

#import "CKVersion.h"
#import "CKResourceManager.h"

//#import <objc/runtime.h>

#define DisclosureImageViewTag  8888991
#define CheckmarkImageViewTag   8888992

@interface CKCollectionCellController()
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isViewAppeared;
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
@synthesize editingMask = _editingMask;

//OverLoads sharedInstance here as CKUITableViewCell has to be inited using a style !
+ (id)sharedInstance{
    static CKUITableViewCell* sharedCKUITableViewCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCKUITableViewCell = [[CKUITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sharedCKUITableViewCell"];
    });
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
    [_checkMarkImage release];
    _checkMarkImage = nil;
    [_delegateRef release];
    _delegateRef = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.syncControllerViewBindingContextId = [NSString stringWithFormat:@"syncControllerViewBindingContextId<%p>",self];
        self.editingMask = UITableViewCellStateDefaultMask;
        self.showsReorderControl = YES;
    }
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(CKTableViewCellController*)thedelegate{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.syncControllerViewBindingContextId = [NSString stringWithFormat:@"syncControllerViewBindingContextId<%p>",self];
        self.delegate = thedelegate;
        self.editingMask = UITableViewCellStateDefaultMask;
        self.showsReorderControl = YES;
    }
	return self;
}

- (id)delegate{
    return self.delegateRef.object;
}

- (void)setDelegate:(CKTableViewCellController *)thedelegate{
    if(_delegateRef){
        [_delegateRef setObject:thedelegate];
    }else{
        self.delegateRef = [CKWeakRef weakRefWithObject:thedelegate];
    }
    
    //Keeps controller in sync for size updates if user sets or bind data directly to the cell !
    /*[NSObject beginBindingsContext:_syncControllerViewBindingContextId options:CKBindingsContextPolicyRemovePreviousBindings];
     [self bind:@"indentationLevel"  toObject:thedelegate withKeyPath:@"indentationLevel"];
     [self.textLabel bind:@"text"  toObject:thedelegate withKeyPath:@"text"];
     [self.detailTextLabel bind:@"text"  toObject:thedelegate withKeyPath:@"detailText"];
     [self.imageView bind:@"image"  toObject:thedelegate withKeyPath:@"image"];
     [self bind:@"accessoryView"  toObject:thedelegate withKeyPath:@"accessoryView"];
     [self bind:@"accessoryType"  toObject:thedelegate withKeyPath:@"accessoryType"];
     [self bind:@"editingAccessoryView"  toObject:thedelegate withKeyPath:@"editingAccessoryView"];
     [self bind:@"editingAccessoryType"  toObject:thedelegate withKeyPath:@"editingAccessoryType"];
     [self bind:@"selectionStyle"  toObject:thedelegate withKeyPath:@"selectionStyle"];
     [NSObject endBindingsContext];	*/
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if([CKOSVersion() floatValue] >= 7){
        if(self.backgroundView){
            self.backgroundView.frame = self.bounds;
        }
    }
    
    if(self.contentView.layoutBoxes && !self.contentView.containerLayoutBox){
        [self.contentView performLayoutWithFrame:self.contentView.bounds];
    }

    if([self.delegate layoutCallback] != nil && self.delegate && [self.delegate respondsToSelector:@selector(layoutCell:)]){
		[self.delegate performSelector:@selector(layoutCell:) withObject:self];
	}
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
                UIImageView* view = (UIImageView*)[self viewWithTag:DisclosureImageViewTag];
                if(!view){
                    view = [[[UIImageView alloc]init]autorelease];
                    view.tag = DisclosureImageViewTag;
                }
                view.image = _disclosureIndicatorImage;
                view.highlightedImage = _highlightedDisclosureIndicatorImage;
                [view sizeToFit];
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
                UIImageView* view = (UIImageView*)[self viewWithTag:DisclosureImageViewTag];
                if(!view){
                    view = [[[UIImageView alloc]init]autorelease];
                    view.tag = DisclosureImageViewTag;
                }
                view.image = _checkMarkImage;
                view.highlightedImage = _highlightedCheckMarkImage;
                [view sizeToFit];
                self.accessoryView = view;
            }
            break;
        }
    }
    
    [super setAccessoryType:theAccessoryType];
}

- (void)setEditingMask:(UITableViewCellStateMask)editingMask{
    if(_editingMask != editingMask){
        UITableViewCellStateMask oldMask = _editingMask;
        _editingMask = editingMask;
        
        if(editingMask == 3 || oldMask == 3){
            //that means delete button shows/hides
            [self.delegate invalidateSize];
        }
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
    
    if(state == UITableViewCellStateShowingDeleteConfirmationMask){
        if([self.delegate.containerController respondsToSelector:@selector(tableViewCellController:displaysDeletionAtIndexPath:)]){
            [self.delegate.containerController performSelector:@selector(tableViewCellController:displaysDeletionAtIndexPath:) withObject:self.delegate withObject:self.delegate.indexPath];
        }
    }else if (self.editingMask == UITableViewCellStateShowingDeleteConfirmationMask && state == UITableViewCellStateDefaultMask){
        if([self.delegate.containerController respondsToSelector:@selector(tableViewCellController:hidesDeletionAtIndexPath:)]){
            [self.delegate.containerController performSelector:@selector(tableViewCellController:hidesDeletionAtIndexPath:) withObject:self.delegate withObject:self.delegate.indexPath];
        }
    }
    
    self.editingMask = state;
    
   
    
    /*NSMutableDictionary* controllerStyle = [self.delegate controllerStyle];
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
     }*/
}

- (void)setHighlighted:(BOOL)highlighted{
    //[self willChangeValueForKey:@"highlighted"];
    [super setHighlighted:highlighted];
    //[self didChangeValueForKey:@"highlighted"];
    
    if(highlighted && self.selectionStyle != UITableViewCellSelectionStyleNone){
        //Push on top of the render stack
        UIView* s = [self superview];
        if([s isKindOfClass:[UITableView class]]){
            UITableViewCell* lastCell = nil;
            for(NSInteger i = [[s subviews]count] - 1; i >= 0; --i){
                UIView* v = [[s subviews]objectAtIndex:i];
                if([v isKindOfClass:[UITableViewCell class]]){
                    lastCell = (UITableViewCell*)v;
                    break;
                }
            }
            if(lastCell != self){
                [self removeFromSuperview];
                [s insertSubview:self aboveSubview:lastCell];
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self willChangeValueForKey:@"highlighted"];
    [super setHighlighted:highlighted animated:animated];
    [self didChangeValueForKey:@"highlighted"];
    
    //if (self.delegate.wantFlatHierarchy)
    //    [self.delegate flattenHierarchyHighlighted:highlighted];
    
    if(highlighted && self.selectionStyle != UITableViewCellSelectionStyleNone){
        //Push on top of the render stack
        UIView* s = [self superview];
        if([s isKindOfClass:[UITableView class]]){
            UITableViewCell* lastCell = nil;
            for(NSInteger i = [[s subviews]count] - 1; i >= 0; --i){
                UIView* v = [[s subviews]objectAtIndex:i];
                if([v isKindOfClass:[UITableViewCell class]]){
                    lastCell = (UITableViewCell*)v;
                    break;
                }
            }
            if(lastCell != self){
                [self removeFromSuperview];
                [s insertSubview:self aboveSubview:lastCell];
            }
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    //[self.delegate restoreViews];
}

- (CGFloat)preferedHeightConstraintToWidth:(CGFloat)width{
    if(self.contentView.layoutBoxes){
        [self.contentView invalidateLayout];
        CGSize size = [self.contentView preferedSizeConstraintToSize:CGSizeMake(width,MAXFLOAT)];
        return size.height;
    }
    return MAXFLOAT;
}

- (CGFloat)preferedWidthConstraintToHeight:(CGFloat)height{
    if(self.contentView.layoutBoxes){
        [self.contentView invalidateLayout];
        CGSize size = [self.contentView preferedSizeConstraintToSize:CGSizeMake(MAXFLOAT,height)];
        return size.width;
    }
    return MAXFLOAT;
}


@end


@interface CKTableViewCellContentViewLayoutProxy : UIView
@end

@implementation CKTableViewCellContentViewLayoutProxy

//Invalidating size when contentView layout boxes are invalidated !

- (void)setLayoutBoxes:(CKArrayCollection *)layoutBoxes{
    UIView* contentView = (UIView*)self;
    
    contentView.invalidatedLayoutBlock = nil;
    
    [super setLayoutBoxes:layoutBoxes];
    
    UITableViewCell* cell = nil;
    if([CKOSVersion() floatValue] < 7){
        cell = (UITableViewCell*)[contentView superview];
    }else{
        cell = (UITableViewCell*)[[contentView superview]superview];
    }
    
    if([cell isKindOfClass:[CKUITableViewCell class]]){
        __block CKUITableViewCell* bcell = (CKUITableViewCell*)cell;
        self.invalidatedLayoutBlock = ^(NSObject<CKLayoutBoxProtocol>* box){
            [bcell.delegate invalidateSize];
        };
    }
}

+ (void)load{
    Class c = NSClassFromString(@"UITableViewCellContentView");
    class_setSuperclass(c,[CKTableViewCellContentViewLayoutProxy class]);
}

@end








@interface CKTableViewCellController ()

@property (nonatomic, retain) NSString* cacheLayoutBindingContextId;

@property (nonatomic, assign) CKTableViewCellController* parentCellController;//In case of grids, ...
@property (nonatomic, retain) CKWeakRef* parentCellControllerRef;//In case of grids, ...

@property (nonatomic, assign) BOOL invalidatedSize;
@property (nonatomic, assign) BOOL isInSetup;
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, assign) BOOL sizeHasBeenQueriedByTableView;

@property (nonatomic, assign) BOOL hasCheckedStyleToReapply;
@property(nonatomic,retain,readwrite) NSMutableDictionary* styleForBackgroundView;
@property(nonatomic,retain,readwrite) NSMutableDictionary* styleForSelectedBackgroundView;

@property (nonatomic, retain) NSMutableDictionary* textLabelStyle;
@property (nonatomic, retain) NSMutableDictionary* detailTextLabelStyle;

- (UITableViewCell *)cellWithStyle:(CKTableViewCellStyle)style;
- (UITableViewCell *)loadCell;

@end

@implementation CKTableViewCellController
@synthesize cellStyle = _cellStyle;
@synthesize componentsRatio = _componentsRatio;
@synthesize horizontalSpace = _horizontalSpace;
@synthesize verticalSpace = _verticalSpace;
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
@synthesize selectionStyle = _selectionStyle;
@synthesize invalidatedSize = _invalidatedSize;
@synthesize sizeBlock = _sizeBlock;
@synthesize parentCellController = _parentCellController;
@synthesize parentCellControllerRef = _parentCellControllerRef;
@synthesize isInSetup = _isInSetup;
@synthesize identifier = _identifier;
@synthesize styleForBackgroundView = _styleForBackgroundView;
@synthesize styleForSelectedBackgroundView = _styleForSelectedBackgroundView;
@synthesize hasCheckedStyleToReapply = _hasCheckedStyleToReapply;
@synthesize textLabelStyle = _textLabelStyle;
@synthesize detailTextLabelStyle = _detailTextLabelStyle;

//used in cell size invalidation process
@synthesize sizeHasBeenQueriedByTableView = _sizeHasBeenQueriedByTableView;

- (void)textExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.multiLineEnabled = YES;
}

- (void)detailTextExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.multiLineEnabled = YES;
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
                                                 CKTableViewCellStyleIPadForm,
                                                 CKTableViewCellStyleIPhoneForm,
                                                 CKTableViewCellStyleSubtitle2,
                                                 CKTableViewCellStyleCustomLayout
                                                 );
}

- (void)accessoryTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellAccessoryType",
                                                 UITableViewCellAccessoryNone, 
                                                 UITableViewCellAccessoryDisclosureIndicator, 
                                                 UITableViewCellAccessoryDetailDisclosureButton,
                                                 UITableViewCellAccessoryCheckmark);
}

- (void)editingAccessoryTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellAccessoryType",
                                                 UITableViewCellAccessoryNone, 
                                                 UITableViewCellAccessoryDisclosureIndicator, 
                                                 UITableViewCellAccessoryDetailDisclosureButton,
                                                 UITableViewCellAccessoryCheckmark);
}

- (void)selectionStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellSelectionStyle",
                                                 UITableViewCellSelectionStyleNone,
                                                 UITableViewCellSelectionStyleBlue,
                                                 UITableViewCellSelectionStyleGray);
}

- (void)editingStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellEditingStyle",
                                                 UITableViewCellEditingStyleNone,
                                                 UITableViewCellEditingStyleDelete,
                                                 UITableViewCellEditingStyleInsert);
}

- (void)postInit {
	[super postInit];
    self.cellStyle = CKTableViewCellStyleDefault;
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        self.componentsRatio = 1.0 / 3.0;
    }
    else{
        self.componentsRatio = 2.0 / 3.0;
    }
    
    self.horizontalSpace = 10;
    self.verticalSpace = 5;
    
    self.size = CGSizeMake(320,44);
    self.flags = CKItemViewFlagSelectable | CKItemViewFlagEditable;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.editingAccessoryType = UITableViewCellAccessoryNone;
    _contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    //self.wantFlatHierarchy = NO;
    
    self.cacheLayoutBindingContextId = [NSString stringWithFormat:@"<%p>_SpecialStyleLayout",self];
    _indentationLevel = 0;
    
    _invalidatedSize = YES;
    _sizeHasBeenQueriedByTableView = NO;
    _hasCheckedStyleToReapply = NO;
    
    self.isInSetup = YES;//do not invalidate size until it has been setuped once.
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
	[_sizeBlock release];
    _sizeBlock = nil;
    [_parentCellControllerRef release];
    _parentCellControllerRef = nil;
    [_identifier release];
    _identifier = nil;
    [_styleForBackgroundView release];
    _styleForBackgroundView = nil;
    [_styleForSelectedBackgroundView release];
    _styleForSelectedBackgroundView = nil;
    [_textLabelStyle release];
    _textLabelStyle = nil;
    [_detailTextLabelStyle release];
    _detailTextLabelStyle = nil;
    
	[super dealloc];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets{
    _contentInsets = contentInsets;
}

- (UIEdgeInsets)contentInsets{
    NSMutableDictionary* style = [self controllerStyle];
    if(style && ![style isEmpty]){
        if([style containsObjectForKey:@"contentInsets"]){
            return [style edgeInsetsForKey:@"contentInsets"];
        }
    }
    return _contentInsets;
}

- (void)setParentCellController:(CKTableViewCellController *)parentCellController{
    self.parentCellControllerRef = [CKWeakRef weakRefWithObject:parentCellController];
}

- (CKTableViewCellController*)parentCellController{
    return [[self parentCellControllerRef]object];
}

- (void)setCellStyle:(CKTableViewCellStyle)cellStyle{
    if(cellStyle != _cellStyle){
        _cellStyle = cellStyle;
        [self invalidateSize];//as stylesheet selection could be dependent
    }
}

- (CKTableViewCellStyle)cellStyle{
    NSMutableDictionary* style = [self controllerStyle];
    if(style && ![style isEmpty]){
        if([style containsObjectForKey:CKStyleCellStyle]){
            return [style cellStyle];
        }
    }
    return _cellStyle;
}

- (void)reapplyStyleForBackgroundViews{
    if([[self styleManager] isEmpty])
        return;
    
    //WE SHOULD OPTIMALLY DO THIS ONLY WHEN INDEXPATH CHANGE FROM FIRST/MIDDLE/LAST
    if(self.tableViewCell){
        CKStyleView* backgroundStyleView = nil;
        CKStyleView* selectedBackgroundStyleView = nil;
        
        if(!_hasCheckedStyleToReapply){
            
            backgroundStyleView = (self.tableViewCell.backgroundView && [self.tableViewCell.backgroundView isKindOfClass:[CKStyleView class]]) 
            ? (CKStyleView*)self.tableViewCell.backgroundView : nil;
            selectedBackgroundStyleView = (self.tableViewCell.selectedBackgroundView && [self.tableViewCell.selectedBackgroundView isKindOfClass:[CKStyleView class]]) 
            ? (CKStyleView*)self.tableViewCell.selectedBackgroundView : nil;
            
            if(backgroundStyleView || selectedBackgroundStyleView){
                
                NSMutableDictionary* style = [self controllerStyle];
                NSMutableDictionary* tableViewCellStyle = [style styleForObject:self.tableViewCell  propertyName:@"tableViewCell"];
                
                if(backgroundStyleView){
                    self.styleForBackgroundView = [tableViewCellStyle styleForObject:self.tableViewCell.backgroundView  propertyName:@"backgroundView"];
                }
                if(selectedBackgroundStyleView){
                    self.styleForSelectedBackgroundView = [tableViewCellStyle styleForObject:self.tableViewCell.selectedBackgroundView  propertyName:@"selectedBackgroundView"];
                }
            }
            
            _hasCheckedStyleToReapply = YES;
        }
        
        if(_styleForBackgroundView){
            if(!backgroundStyleView){
                backgroundStyleView = (self.tableViewCell.backgroundView && [self.tableViewCell.backgroundView isKindOfClass:[CKStyleView class]]) 
                ? (CKStyleView*)self.tableViewCell.backgroundView : nil;
            }
            backgroundStyleView.corners = [self view:self.tableViewCell.backgroundView cornerStyleWithStyle:_styleForBackgroundView];
            backgroundStyleView.borderLocation = [self view:self.tableViewCell.backgroundView borderStyleWithStyle:_styleForBackgroundView];
            backgroundStyleView.separatorLocation = [self view:self.tableViewCell.backgroundView separatorStyleWithStyle:_styleForBackgroundView];
        }
        
        if(_styleForSelectedBackgroundView){
            if(!selectedBackgroundStyleView){
                selectedBackgroundStyleView = (self.tableViewCell.selectedBackgroundView && [self.tableViewCell.selectedBackgroundView isKindOfClass:[CKStyleView class]]) 
                ? (CKStyleView*)self.tableViewCell.selectedBackgroundView : nil;
            }
            selectedBackgroundStyleView.corners = [self view:self.tableViewCell.selectedBackgroundView cornerStyleWithStyle:_styleForSelectedBackgroundView];
            selectedBackgroundStyleView.borderLocation = [self view:self.tableViewCell.selectedBackgroundView borderStyleWithStyle:_styleForSelectedBackgroundView];
            selectedBackgroundStyleView.separatorLocation = [self view:self.tableViewCell.selectedBackgroundView separatorStyleWithStyle:_styleForSelectedBackgroundView];
        }
    }
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    if([self.indexPath isEqual:indexPath] == NO){
        [super setIndexPath:indexPath];
    }
    
    if([self.tableViewCell superview]){
        [self reapplyStyleForBackgroundViews];
    }
}

- (void)setName:(NSString *)name{
    if([self.name isEqual:name] == NO){
        [super setName:name];
    }
}

- (void)setValue:(id)value{
    if([self.value isEqual:value] == NO){
        [super setValue:value];
        [self onValueChanged];
        
        if([self.tableViewCell superview]){
            [self invalidateSize];
        }
    }
}

+ (id)cellController{
    return [[[[self class]alloc]init]autorelease];
}

+ (id)cellControllerWithName:(NSString*)name{
    id controller = [[[[self class]alloc]init]autorelease];
    [controller setName:name];
    return controller;
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
		CKAssert([self.view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
		return (UITableViewCell*)self.view;
	}
	return nil;
}

#pragma mark Cell Factory
- (UITableViewCell *)cellWithStyle:(CKTableViewCellStyle)style {
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	CKTableViewCellStyle thecellStyle = style;
	if([controllerStyle containsObjectForKey:CKStyleCellStyle]){
		thecellStyle = [controllerStyle cellStyle];
    }
    
	self.cellStyle = thecellStyle;
	
    //Redirect cell style to a known style for UITableViewCell initialization
    //The layoutCell method will then adapt the layout to our custom type of cell
	CKTableViewCellStyle toUseCellStyle = thecellStyle;
	if(toUseCellStyle == CKTableViewCellStyleIPadForm
       ||toUseCellStyle == CKTableViewCellStyleIPhoneForm){
		toUseCellStyle = CKTableViewCellStyleValue1;
	}
    else if(toUseCellStyle == CKTableViewCellStyleSubtitle2
            || toUseCellStyle == CKTableViewCellStyleCustomLayout){
		toUseCellStyle = CKTableViewCellStyleSubtitle;
    }
    
	CKUITableViewCell *cell = [[[CKUITableViewCell alloc] initWithStyle:(UITableViewCellStyle)toUseCellStyle reuseIdentifier:[self identifier] delegate:self] autorelease];
	
	return cell;
}

- (NSString *)identifier {
    if(_identifier == nil || [CKResourceManager isResourceManagerConnected]){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        if(self.createCallback){
            [self.createCallback execute:self];
            if([controllerStyle containsObjectForKey:CKStyleCellStyle]){
                self.cellStyle = [controllerStyle cellStyle];
            }
        }
        
        [_identifier release];
        _identifier =  [[NSString stringWithFormat:@"%@-<%p>-[%@]-<%ld>",[[self class] description],controllerStyle,self.name ? self.name : @"", (long)self.cellStyle]retain];
    }
    return _identifier;
}

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:self.cellStyle];
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	return;
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	if(self.cellStyle == CKTableViewCellStyleIPadForm
       || self.cellStyle == CKTableViewCellStyleIPhoneForm
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        //Ensure detailTextLabel is created !
        if(cell.detailTextLabel == nil){
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,100,44)];
            object_setInstanceVariable(cell, "_detailTextLabel", (void**)(label));
        }
	}
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	if(self.cellStyle == CKTableViewCellStyleIPadForm){
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
    else if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
        cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
        
        //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        //}
        //else{
        //    cell.textLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        //    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        //    cell.detailTextLabel.textColor = [UIColor blackColor];
        //    cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        //    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        //    cell.textLabel.textAlignment = UITextAlignmentRight;
        //}
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
}

- (void)cellDidDisappear {
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


#pragma mark CKCollectionCellController Implementation

- (UIView *)loadView{
    /*[CATransaction begin];
     [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];*/
    
	UITableViewCell* cell = [self loadCell];
    self.view = cell;
    
	[self initView:cell];
	[self layoutCell:cell];
    
    //[CATransaction commit];
	
	return cell;
}

- (void)initView:(UIView*)view{
    [NSObject removeAllBindingsForContext:_cacheLayoutBindingContextId];
    
	CKAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
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
        
       // NSMutableDictionary* style = [self stylesheet];
        //NSMutableDictionary* cellStyle = [style styleForObject:self.tableViewCell propertyName:@"tableViewCell"];
        [self applyStyle];
    }
}

- (void)setFlags:(CKItemViewFlags)theflags{
    if(self.flags == theflags)
        return;
    
    [super setFlags:theflags];
    
    if(self.tableViewCell){
        self.tableViewCell.selectionStyle = (self.flags & CKItemViewFlagSelectable) ? self.selectionStyle : UITableViewCellSelectionStyleNone;
    }
    
    if(self.tableViewCell){
        // NSMutableDictionary* style = [self stylesheet];
        //NSMutableDictionary* cellStyle = [style styleForObject:self.tableViewCell propertyName:@"tableViewCell"];
        [self applyStyle];
    }
}

- (void)setupView:(UIView *)view{
    self.isInSetup = YES;
    
    [self reapplyStyleForBackgroundViews];
    
    if(self.layoutCallback == nil){
        self.layoutCallback = [CKCallback callbackWithBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            
            BOOL enabled = [UIView areAnimationsEnabled];
            [UIView setAnimationsEnabled:NO];
            
            //[CATransaction disableActions];
            [controller performLayout];
 
            //[CATransaction commit];
            [UIView setAnimationsEnabled:enabled];
            
            return (id)nil;
        }];
    }
    
	CKAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
    
    UITableViewCell* cell = (UITableViewCell*)view;
    cell.indentationLevel = self.indentationLevel;
    cell.selectionStyle = (self.flags & CKItemViewFlagSelectable) ? self.selectionStyle : UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.text;
    cell.detailTextLabel.text = self.detailText;
    cell.imageView.image = self.image;
    cell.accessoryView = self.accessoryView;
    if(!self.accessoryView) cell.accessoryType = self.accessoryType;
    cell.editingAccessoryView = self.editingAccessoryView;
    if(!self.editingAccessoryView) cell.editingAccessoryType = self.editingAccessoryType;
    
	[self setupCell:cell];
	[super setupView:view];
    
    self.isInSetup = NO;
}

- (void)rotateView:(UIView*)view animated:(BOOL)animated{
    self.invalidatedSize = YES;
	[super rotateView:view animated:animated];
	[self rotateCell:(UITableViewCell*)view animated:animated];
}

- (void)viewDidAppear:(UIView *)view{
	CKAssert([view isKindOfClass:[UITableViewCell class]],@"Invalid view type");
    if(!self.isViewAppeared){
        [self cellDidAppear:(UITableViewCell*)view];
    }
	[super viewDidAppear:view];
}

- (void)viewDidDisappear{
    if(self.isViewAppeared){
        [self cellDidDisappear];
        self.isViewAppeared = NO;
    }
	[super viewDidDisappear];
}

- (NSIndexPath *)willSelect{
	return [self willSelectRow];
}

- (void)didSelect{
	if([self.containerController isKindOfClass:[CKTableViewController class]]){
		CKTableViewController* tableViewController = (CKTableViewController*)self.containerController;
		if (tableViewController.stickySelectionEnabled == NO){
            if(self.parentCellController){
                [self.tableViewCell setHighlighted:NO animated:NO];
                [self.tableViewCell setSelected:NO animated:NO];
            }else{
                [tableViewController.tableView deselectRowAtIndexPath:self.indexPath animated:YES];
            }
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
    CKAssert([self.containerController isKindOfClass:[CKTableViewController class]],@"invalid parent controller class");
    CKTableViewController* tableViewController = (CKTableViewController*)self.containerController;
    [tableViewController.tableView scrollToRowAtIndexPath:self.indexPath 
                                         atScrollPosition:UITableViewScrollPositionMiddle 
                                                 animated:YES];
}

- (void)scrollToRowAfterDelay:(NSTimeInterval)delay{
    [self performSelector:@selector(scrollToRow) withObject:nil afterDelay:delay];
}

@end