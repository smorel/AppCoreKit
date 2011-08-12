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

@interface CKPropertyGridCellController () 
@property(nonatomic,retain)UIButton* validationButton;
@end

@implementation CKPropertyGridCellController
@synthesize readOnly = _readOnly;
@synthesize validationButton = _validationButton;

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
	return self;
}

- (void)dealloc{
    [_validationButton release];
    _validationButton = nil;
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
    
    [self beginBindingsContextByKeepingPreviousBindings];
    [cell bind:@"backgroundColor" withBlock:^(id value) {
        BOOL validity = [self isValidValue:[[self objectProperty] value]];
        [self setInvalidButtonVisible:!validity];
    }];
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
    BOOL validity = [self isValidValue:value];
    [self setInvalidButtonVisible:!validity];
    
    CKObjectProperty* property = [self objectProperty];
    [property setValue:value];
    [[NSNotificationCenter defaultCenter]notifyPropertyChange:property];
}

- (CGRect)rectForValidationButtonWithCell:(UITableViewCell*)cell{
    if(!_validationButton)
        return CGRectMake(0,0,0,0);
    
    UIView* contentView = cell.contentView;
    CGRect contentRect = contentView.frame;
    CGFloat x = MAX(_validationButton.frame.size.width / 2.0,contentRect.origin.x / 2.0);
    
    
    CGRect buttonRect = CGRectMake( self.tableViewCell.frame.size.width - x - _validationButton.frame.size.width / 2.0,
                                   self.tableViewCell.frame.size.height / 2.0 - _validationButton.frame.size.height / 2.0,
                                   _validationButton.frame.size.width,
                                   _validationButton.frame.size.height);
    return CGRectIntegral(buttonRect);
}

- (void)setInvalidButtonVisible:(BOOL)visible{
    if(self.view == nil)
        return;
    
   if(visible){
        if(_validationButton == nil){
            self.validationButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
            [_validationButton addTarget:self action:@selector(validationInfos:) forControlEvents:UIControlEventTouchUpInside];
        }
         
       _validationButton.frame = [self rectForValidationButtonWithCell:self.tableViewCell];
        [self.tableViewCell addSubview:_validationButton];
    }
    else if(_validationButton){
        [_validationButton removeFromSuperview];
    }
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
    if(controller.validationButton != nil){
        controller.validationButton.frame = [controller rectForValidationButtonWithCell:controller.tableViewCell];
    }
    return (id)nil;
}

@end
