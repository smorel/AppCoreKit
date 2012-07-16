//
//  CKPropertyGridCellController.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKAlertView.h"
#import "CKFormTableViewController.h"
#import "CKBundle.h"
#import "CKTableViewCellNextResponder.h"
#import "CKSheetController.h"

#import <QuartzCore/QuartzCore.h>

#define CLICKABLE_VALIDATION_INFO 0

@interface CKPropertyGridCellController () 
@property(nonatomic,retain)UIButton* validationButton;
@property(nonatomic,retain)UIImageView* validationImageView;
@property(nonatomic,retain)UIView* oldAccessoryView;
@property(nonatomic,assign)UITableViewCellAccessoryType oldAccessoryType;
@property(nonatomic,retain)NSString* validationBindingContext;

@end

@implementation CKPropertyGridCellController
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
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
    _validationDisplayed = NO;
    self.validationBindingContext = [NSString stringWithFormat:@"<%p>_validation",self];
    _fixedSize = NO;
    self.enableNavigationToolbar = NO;
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

- (CKObjectProperty*)objectProperty{
    NSAssert(self.value == nil || [self.value isKindOfClass:[CKObjectProperty class]],@"Invalid value type");
    return (CKObjectProperty*)self.value;
}

- (void)setValue:(id)value{
    if(![self.value isEqual:value]){
        NSAssert(value == nil || [value isKindOfClass:[CKObjectProperty class]],@"Invalid value type");
        [super setValue:value];
    }
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
    if([[self parentController]isKindOfClass:[CKFormTableViewController class]]){
        CKFormTableViewController* form = (CKFormTableViewController*)[self parentController];
        [form bind:@"validationEnabled" withBlock:^(id value) {
            BOOL validity = [self isValidValue:[[self objectProperty] value]];
            [self setInvalidButtonVisible:!validity];
        }];
    }
    
    CKObjectProperty* property = [self objectProperty];
    Class propertyType = [property type];
    if(propertyType != nil && [NSObject isKindOf:propertyType parentType:[CKDocumentCollection class]]){
        [property.object bind:[NSString stringWithFormat:@"%@.count",property.keyPath] withBlock:^(id value) {
            BOOL validity = [self isValidValue:[[self objectProperty] value]];
            [self setInvalidButtonVisible:!validity];
        }];
    }
    [NSObject endBindingsContext];
    
    BOOL validity = [self isValidValue:[[self objectProperty] value]];
    [self setInvalidButtonVisible:!validity];
}

- (BOOL)isValidValue:(id)value{
    CKObjectProperty* property = [self objectProperty];
    CKObjectPropertyMetaData* metaData = [property metaData];
    if(metaData.validationPredicate){
        return [metaData.validationPredicate evaluateWithObject:value];
    }
    return YES;
}

- (void)setValueInObjectProperty:(id)value{
    BOOL validity = [self isValidValue:value];
    
    CKFormTableViewController* form = (CKFormTableViewController*)[self parentController];
    BOOL visible = !validity && form.validationEnabled;
    BOOL validityStateChanged = (_validationDisplayed != visible);
    if(validityStateChanged){
        //appeller seulement quand changement d'etat de validation ET parentForm validationEnabled
        BOOL hasAnimation = NO;
        if(!_fixedSize){
            CALayer* layer = [self.tableViewCell layer];
            NSArray* anims = [layer animationKeys];
            hasAnimation = ([anims count] > 0);
            if(!hasAnimation && ([form state] & CKUIViewControllerStateDidAppear)){
                [[self parentTableView]beginUpdates];
            }
        }
        
        [self setInvalidButtonVisible:!validity];
        [self layoutCell:self.tableViewCell];
        
        
        if(!_fixedSize){
            //appeller seulement quand changement d'etat de validation ET parentForm validationEnabled
            if(!hasAnimation && ([form state] & CKUIViewControllerStateDidAppear)){
                [[self parentTableView]endUpdates];
            }
        }
    }
    
    CKObjectProperty* property = [self objectProperty];
    [property setValue:value];
    [[NSNotificationCenter defaultCenter]notifyPropertyChange:property];
}

- (CGRect)rectForValidationButtonWithCell:(UITableViewCell*)cell{
    UIImage* img = CLICKABLE_VALIDATION_INFO ? (UIImage*)[self.validationButton currentImage] : (UIImage*)[self.validationImageView image];
    
    if(!img)
        return CGRectMake(0,0,0,0);
    
    UIView* contentView = cell.contentView;
    CGRect contentRect = contentView.frame;
    CGFloat x = MAX(img.size.width / 2.0,contentRect.origin.x / 2.0);
    
    
    CGRect buttonRect = CGRectMake( self.tableViewCell.frame.size.width - x - img.size.width / 2.0,
                                   self.tableViewCell.frame.size.height / 2.0 - img.size.height / 2.0,
                                   img.size.width,
                                   img.size.height);
    return CGRectIntegral(buttonRect);
}

- (void)setInvalidButtonVisible:(BOOL)visible{
    if(self.view == nil)
        return;
    
    if([[self parentController]isKindOfClass:[CKFormTableViewController class]]){
        CKFormTableViewController* form = (CKFormTableViewController*)[self parentController];
        visible = visible && form.validationEnabled;
        BOOL shouldReplaceAccessoryView = (   [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone
                                           || [self parentTableView].style == UITableViewStylePlain );
        
        if(visible && !_validationDisplayed){
            UIImage* image = [CKBundle imageForName:@"form-icon-invalid"];
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
                self.oldAccessoryView = self.tableViewCell.accessoryView;
                self.oldAccessoryType = self.tableViewCell.accessoryType;
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
                    self.tableViewCell.accessoryView = self.oldAccessoryView;
                    self.tableViewCell.accessoryType = self.oldAccessoryType;
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
    CKObjectProperty* property = [self objectProperty];
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

- (id)performStandardLayout:(CKPropertyGridCellController*)controller{
    [super performStandardLayout:controller];
    [self performValidationLayout:controller];
    return (id)nil;
}

- (void)performValidationLayout:(CKPropertyGridCellController*)controller{
    if(controller.validationButton != nil
       || controller.validationImageView != nil){
        BOOL shouldReplaceAccessoryView = (   [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone
                                           || [self parentTableView].style == UITableViewStylePlain );
        if(!shouldReplaceAccessoryView){
            UIView* newAccessoryView = CLICKABLE_VALIDATION_INFO ? (UIView*)controller.validationButton : (UIView*)controller.validationImageView;
            newAccessoryView.frame = [controller rectForValidationButtonWithCell:controller.tableViewCell];
        }
    }
}

- (void)previous:(id)sender{
    [CKTableViewCellNextResponder activatePreviousResponderFromController:self];
}

- (void)next:(id)sender{
    [CKTableViewCellNextResponder activateNextResponderFromController:self];
}

- (void)done:(id)sender{
    [self.parentController.view endEditing:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
}

- (UIToolbar*)navigationToolbar{
    if(!self.enableNavigationToolbar)
        return nil;
    
    if(_navigationToolbar == nil){
        UIToolbar* toolbar = [[[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)]autorelease];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        
        BOOL hasNextResponder = [CKTableViewCellNextResponder needsNextKeyboard:self];
        BOOL hasPreviousResponder = [CKTableViewCellNextResponder needsPreviousKeyboard:self];
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
        
        CKObjectProperty* model = self.value;
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
        
        toolbar.items = buttons;
        
        return toolbar;
        
        //Do not retain it as we reuse controllers : To fix when no more controller reuse.
        //_navigationToolbar = [toolbar retain];
    }
    
    return _navigationToolbar;
}

@end
