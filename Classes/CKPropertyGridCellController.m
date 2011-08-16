//
//  CKPropertyGridCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-08.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKAlertView.h"
#import "CKFormTableViewController.h"
#import "CKBundle.h"

#import <QuartzCore/QuartzCore.h>

#define CLICKABLE_VALIDATION_INFO 0

@interface CKPropertyGridCellController () 
@property(nonatomic,retain)UIButton* validationButton;
@property(nonatomic,retain)UIImageView* validationImageView;
@property(nonatomic,retain)UIView* oldAccessoryView;
@property(nonatomic,assign)UITableViewCellAccessoryType oldAccessoryType;
@end

@implementation CKPropertyGridCellController
@synthesize readOnly = _readOnly;
@synthesize validationButton = _validationButton;
@synthesize oldAccessoryView = _oldAccessoryView;
@synthesize oldAccessoryType = _oldAccessoryType;
@synthesize validationImageView = _validationImageView;

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
    _validationDisplayed = NO;
	return self;
}

- (void)dealloc{
    [NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"<%p>_validation",self]];
    [_validationButton release];
    _validationButton = nil;
    [_oldAccessoryView release];
    _oldAccessoryView = nil;
    [_validationImageView release];
    _validationImageView = nil;
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
    
        BOOL validity = [self isValidValue:[value value]];
        [self setInvalidButtonVisible:!validity];
    }
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
    if(self.readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    BOOL validity = [self isValidValue:[[self objectProperty] value]];
    [self setInvalidButtonVisible:!validity];
}


- (void)setupCell:(UITableViewCell*)cell{
    [super setupCell:cell];

    [NSObject beginBindingsContext:[NSString stringWithFormat:@"<%p>_validation",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
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
    [self endBindingsContext];
}

- (BOOL)isValidValue:(id)value{
    CKObjectProperty* property = [self objectProperty];
    CKModelObjectPropertyMetaData* metaData = [property metaData];
    if(metaData.validationPredicate){
        return [metaData.validationPredicate evaluateWithObject:value];
    }
    return YES;
}

- (void)setValueInObjectProperty:(id)value{
    CALayer* layer = [self.tableViewCell layer];
    NSArray* anims = [layer animationKeys];
    BOOL hasAnimation = ([anims count] > 0);
    if(!hasAnimation){
        [[self parentTableView]beginUpdates];
    }
    BOOL validity = [self isValidValue:value];
    [self setInvalidButtonVisible:!validity];

    [self layoutCell:self.tableViewCell];
    
    if(!hasAnimation){
        [[self parentTableView]endUpdates];
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
                _oldAccessoryView = self.tableViewCell.accessoryView;
                _oldAccessoryType = self.tableViewCell.accessoryType;
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
                    self.tableViewCell.accessoryView = _oldAccessoryView;
                    self.tableViewCell.accessoryType = _oldAccessoryType;
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

@end
