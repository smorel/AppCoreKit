//
//  CKPropertyGridCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-08.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKPropertyGridCellController+CKDynamicLayout.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKAlertView.h"
#import "CKFormTableViewController.h"
#import "CKTableViewCellController+Responder.h"
#import "CKSheetController.h"

#import "CKTableViewCellController+Style.h"

#import <QuartzCore/QuartzCore.h>

@interface CKPropertyGridCellController () 
@property(nonatomic,retain)UIButton* validationButton;
@property(nonatomic,retain)UIImageView* validationImageView;
@property(nonatomic,retain)UIView* oldAccessoryView;
@property(nonatomic,assign)UITableViewCellAccessoryType oldAccessoryType;
@property(nonatomic,retain)NSString* validationBindingContext;

- (void)setInvalidButtonVisible:(BOOL)visible;

@end

@implementation CKPropertyGridCellController{
    UIButton* _validationButton;
    UIImageView* _validationImageView;
    UIView* _oldAccessoryView;
    UITableViewCellAccessoryType _oldAccessoryType;
    BOOL _validationDisplayed;
    NSString* _validationBindingContext;
    
    BOOL _fixedSize;
}

@synthesize readOnly = _readOnly;
@synthesize validationButton = _validationButton;
@synthesize oldAccessoryView = _oldAccessoryView;
@synthesize oldAccessoryType = _oldAccessoryType;
@synthesize validationImageView = _validationImageView;
@synthesize validationBindingContext = _validationBindingContext;
@synthesize fixedSize = _fixedSize;
@synthesize enableNavigationToolbar;
@synthesize navigationToolbar = _navigationToolbar;

- (id)init{
    if (self = [super init]) {
        self.cellStyle = CKTableViewCellStyleIPhoneForm;
        _validationDisplayed = NO;
        self.validationBindingContext = [NSString stringWithFormat:@"<%p>_validation",self];
        _fixedSize = NO;
        self.enableNavigationToolbar = NO;
    }
	return self;
}

- (void)dealloc{
    [NSObject removeAllBindingsForContext:_validationBindingContext];
    [_validationButton release];
    _validationButton = nil;
    [_oldAccessoryView release];
    _oldAccessoryView = nil;
    [_validationImageView release];
    _validationImageView = nil;
    [_validationBindingContext release];
    _validationBindingContext = nil;
    [_navigationToolbar release];
    _navigationToolbar = nil;
    [super dealloc];
}

- (CKProperty*)objectProperty{
    NSAssert(self.value == nil || [self.value isKindOfClass:[CKProperty class]],@"Invalid value type");
    return (CKProperty*)self.value;
}

- (void)setValue:(id)value{
    if(![self.value isEqual:value]){
        NSAssert(value == nil || [value isKindOfClass:[CKProperty class]],@"Invalid value type");
        [super setValue:value];
    }
}

- (void)setReadOnly:(BOOL)readOnly{
    _readOnly = readOnly;
    if(self.tableViewCell){
        [self setupCell:self.tableViewCell];
    }
    [self invalidateSize];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
    if(self.readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setupCell:(UITableViewCell*)cell{
    [super setupCell:cell];

    [NSObject beginBindingsContext:_validationBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
    if([[self containerController]isKindOfClass:[CKFormTableViewController class]]){
        CKFormTableViewController* form = (CKFormTableViewController*)[self containerController];
        [form bind:@"validationEnabled" withBlock:^(id value) {
            BOOL validity = [self isValidValue:[[self objectProperty] value]];
            [self setInvalidButtonVisible:!validity];
        }];
    }
    
    CKProperty* property = [self objectProperty];
    Class propertyType = [property type];
    if(propertyType != nil && [NSObject isClass:propertyType kindOfClass:[CKCollection class]]){
        [property.object bind:[NSString stringWithFormat:@"%@.count",property.keyPath] withBlock:^(id value) {
            BOOL validity = [self isValidValue:[[self objectProperty] value]];
            [self setInvalidButtonVisible:!validity];
        }];
    }
    
    __block CKTableViewCellController* bSelf = self;
    [property.object bind:property.keyPath withBlock:^(id value) {
        [bSelf invalidateSize];
    }];
    
    [NSObject endBindingsContext];
    
    BOOL validity = [self isValidValue:[[self objectProperty] value]];
    [self setInvalidButtonVisible:!validity];
}

- (BOOL)isValidValue:(id)value{
    CKProperty* property = [self objectProperty];
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    if(attributes.validationPredicate){
        return [attributes.validationPredicate evaluateWithObject:value];
    }
    return YES;
}

- (void)setValueInObjectProperty:(id)value{
    BOOL validity = [self isValidValue:value];
    
    CKFormTableViewController* form = (CKFormTableViewController*)[self containerController];
    BOOL visible = !validity && form.validationEnabled;
    BOOL validityStateChanged = (_validationDisplayed != visible);
    if(validityStateChanged){
        [self setInvalidButtonVisible:!validity];
        [self layoutCell:self.tableViewCell];
    }
    
    CKProperty* property = [self objectProperty];
    [property setValue:value];
}

- (void)setInvalidButtonVisible:(BOOL)visible{
    if(self.view == nil)
        return;
    
    if([[self containerController]isKindOfClass:[CKFormTableViewController class]]){
        CKFormTableViewController* form = (CKFormTableViewController*)[self containerController];
        visible = visible && form.validationEnabled;
        BOOL shouldReplaceAccessoryView = (   [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone
                                           || [self parentTableView].style == UITableViewStylePlain );
        
        if(visible && !_validationDisplayed){
            UIImage* image = [UIImage imageNamed:@"form-icon-invalid"];
            if(CLICKABLE_VALIDATION_INFO && _validationButton == nil){
                self.validationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _validationButton.frame = CGRectMake(0,0,image.size.width,image.size.height);
                [_validationButton setImage:image forState:UIControlStateNormal];
                [_validationButton addTarget:self action:@selector(validationInfos:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if(!CLICKABLE_VALIDATION_INFO && _validationImageView == nil){
                self.validationImageView = [[[UIImageView alloc]initWithImage:image]autorelease];
                _validationImageView.frame = CGRectMake(0,0,image.size.width,image.size.height);
            }
            
            UIView* newAccessoryView = CLICKABLE_VALIDATION_INFO ? (UIView*)_validationButton : (UIView*)_validationImageView;
            if(shouldReplaceAccessoryView){
                self.oldAccessoryView = self.accessoryView;
                self.oldAccessoryType = self.accessoryType;
                self.tableViewCell.accessoryView = newAccessoryView;
            }
            else{
                newAccessoryView.frame = [self rectForValidationButtonWithCell:self.tableViewCell];
                [self.tableViewCell addSubview:newAccessoryView];
            }
            _validationDisplayed = YES;
        }
        else if(!visible && _validationDisplayed){
            UIView* newAccessoryView = CLICKABLE_VALIDATION_INFO ? (UIView*)_validationButton : (UIView*)_validationImageView;
            if(newAccessoryView){
                if(shouldReplaceAccessoryView){
                    self.accessoryView = self.oldAccessoryView;
                    self.accessoryType = self.oldAccessoryType;
                }
                else{
                    [newAccessoryView removeFromSuperview];
                }
            }
            _validationDisplayed = NO;
        }
    }
    
    /* FIXME : Here it can change the height as we set an accessory view ...
    table view should be notified that it should recompute the size of the cells.
    [[self parentTableView]beginUpdates];
    [[self parentTableView]endUpdates];
     */
}

- (void)validationInfos:(id)sender{
    CKProperty* property = [self objectProperty];
    CKClassPropertyDescriptor* descriptor = [property descriptor];
    NSString* titleId = [NSString stringWithFormat:@"%@_Validation_Title",descriptor.name];
    NSString* messageId = [NSString stringWithFormat:@"%@_Validation_Message",descriptor.name];
    
    NSString* title = _(titleId);
    NSString* message = _(messageId);
    if([title length] > 0 && [message length] > 0){
        CKAlertView* alert = [[[CKAlertView alloc ]initWithTitle:title message:message]autorelease];
        [alert addButtonWithTitle:_(@"Ok") action:nil];
        [alert show];
    }
}

- (void)previous:(id)sender{
    [self activatePreviousResponder];
}

- (void)next:(id)sender{
    [self activateNextResponder];
}

- (void)done:(id)sender{
    [self.containerController.view endEditing:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
}

- (UIToolbar*)navigationToolbar{
    if(!self.enableNavigationToolbar)
        return nil;
    
    if(_navigationToolbar == nil){
        UIToolbar* toolbar = [[[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)]autorelease];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        _navigationToolbar = [toolbar retain];
    }
    
    if(self.containerController.state == CKViewControllerStateDidAppear){
        BOOL hasNextResponder = [self hasNextResponder];
        BOOL hasPreviousResponder = [self hasPreviousResponder];
        NSMutableArray* buttons = [NSMutableArray array];
        {
            UIBarButtonItem* button = [[[UIBarButtonItem alloc]initWithTitle:_(@"Previous")
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self 
                                                                      action:@selector(previous:)]autorelease];
            button.enabled = hasPreviousResponder;
            [buttons addObject:button];
        }
        
        UIBarButtonItem* button = [[[UIBarButtonItem alloc]initWithTitle:hasNextResponder ? _(@"Next") : _(@"Done") 
                                                                   style:hasNextResponder ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:hasNextResponder ? @selector(next:) : @selector(done:)]autorelease];
        [buttons addObject:button];
        
        CKProperty* model = self.value;
        CKClassPropertyDescriptor* descriptor = [model descriptor];
        NSString* str = [NSString stringWithFormat:@"%@_NavigationBar",descriptor.name];
        NSString* title = _(str);
        if([title isKindOfClass:[NSString class]] && [title length] > 0){
            UILabel* titleLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0,0,200,44)]autorelease];
            titleLabel.text = title;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            UIBarButtonItem* titleItem = [[[UIBarButtonItem alloc]initWithCustomView:titleLabel]autorelease];
            [buttons addObject:titleItem];
        }
        
        _navigationToolbar.items = buttons;
        
        NSMutableDictionary* dico = [self controllerStyle];
        [_navigationToolbar applyStyle:dico propertyName:@"navigationToolbar"];
    }

    
    return _navigationToolbar;
}

@end
