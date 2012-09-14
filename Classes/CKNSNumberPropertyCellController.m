//
//  CKNSNumberPropertyCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSNumberPropertyCellController.h"
#import "CKNSNumberPropertyCellController+DynamicLayout.h"
#import "CKProperty.h"
#import "NSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+Positioning.h"

@interface CKNSNumberPropertyCellController()
@property (nonatomic,retain,readwrite) UITextField* textField;
@property (nonatomic,retain,readwrite) UISwitch* toggleSwitch;
@end

@implementation CKNSNumberPropertyCellController{	
	UITextField* _textField;
	UISwitch* _toggleSwitch;
}

@synthesize textField = _textField;
@synthesize toggleSwitch = _toggleSwitch;
@synthesize textInputFormatterBlock = _textInputFormatterBlock;

-(void)dealloc{
	[_textField release];
	[_toggleSwitch release];
    [_textInputFormatterBlock release];
	[super dealloc];
}

- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

- (void)onswitch{
	UISwitch* s = (UISwitch*)[self.tableViewCell viewWithTag:500002];
    [self setValueInObjectProperty:[NSNumber numberWithBool:s.on]];
}

- (void)onvalue{
	CKProperty* model = self.objectProperty;
	BOOL bo = [[model value] boolValue];
	
	UISwitch* s = (UISwitch*)[self.tableViewCell viewWithTag:500002];
	[s setOn:bo animated:YES];
}

- (void)textFieldChanged:(id)thevalue{
    CKProperty* property = (CKProperty*)self.objectProperty;
	NSNumber* number = (NSNumber*)[property value];
	NSNumber* newNumber = [NSValueTransformer transform:self.textField.text toClass:[NSNumber class]];
    
	if(newNumber == nil){
        [self setValueInObjectProperty:[NSNumber numberWithInt:0]];
	}
	else if(![number isEqualToNumber:newNumber]){
        [self setValueInObjectProperty:newNumber];
	}
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    if(newNumber && attributes.placeholderValue && [attributes.placeholderValue isEqualToNumber:newNumber]){
        if(self.textField.text != nil){
            self.textField.text = nil;
        }
    }
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    UITextField *txtField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
    self.textField = txtField;
    
	_textField.tag = 50000;
	_textField.borderStyle = UITextBorderStyleNone;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_textField.keyboardType = UIKeyboardTypeDecimalPad;
	_textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _textField.hidden = YES; //will get displayed in setup depending on the model
    [cell.contentView addSubview:_textField];
    
    if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
        //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            _textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            _textField.textAlignment = UITextAlignmentRight;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        //}  
        //else{
        //    _textField.textColor = [UIColor blackColor];
        //    _textField.textAlignment = UITextAlignmentLeft;
        //    cell.detailTextLabel.numberOfLines = 0;
        //    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        //}
    }  
    
    if(self.cellStyle == CKTableViewCellStyleIPadForm
       || self.cellStyle == CKTableViewCellStyleIPhoneForm){
        _textField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    /*
    UISwitch *theSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(0,0,100,100)] autorelease];
    self.toggleSwitch = theSwitch;
    
    _toggleSwitch.hidden = YES; //will get displayed in setup depending on the model
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad ||
       ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone && self.cellStyle == CKTableViewCellStyleIPadForm)){
        [cell.contentView addSubview:self.toggleSwitch];
    }
    else{
        cell.accessoryView = self.toggleSwitch;
    }

    _toggleSwitch.tag = 500002;
    */
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[cell clearBindingsContext];
    
    //In Case view is reused
    self.textField = (UITextField*)[cell.contentView viewWithTag:50000];
	_textField.delegate = self;
    
    
    UISwitch* theSwitch = (UISwitch*)[cell viewWithTag:500002];
    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    [theSwitch removeFromSuperview];
	
	
	CKProperty* model = self.objectProperty;
	
	//build and setup the view
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	self.text = _(descriptor.name);
    
    __block CKNSNumberPropertyCellController* bself = self;
	if([self isNumber]){
        if([model isReadOnly] || self.readOnly){
            self.fixedSize = YES;
            [cell beginBindingsContextByRemovingPreviousBindings];
            [model.object bind:model.keyPath toObject:self withKeyPath:@"detailText"];
            [cell endBindingsContext];
            _textField.hidden = YES;
        }
        else{
            if(self.cellStyle == CKTableViewCellStyleIPhoneForm
               /*&& [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone*/){
                self.fixedSize = YES;
            }
            else{
                self.fixedSize = NO;
            }
            _textField.hidden = NO;
            
            [cell beginBindingsContextByRemovingPreviousBindings];
            [model.object bind:model.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
                CKPropertyExtendedAttributes* attributes = [model extendedAttributes];
                if(attributes.placeholderValue && [attributes.placeholderValue isEqualToNumber:[model value]]){
                    if(bself.textField.text != nil){
                        bself.textField.text = nil;
                    }
                }else{
                    NSString* str = [NSValueTransformer transform:value toClass:[NSString class]];
                    if(![bself.textField.text isEqualToString:str]){
                        bself.textField.text = str;
                    }
                }
            }];
            [cell endBindingsContext];
            
            NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
            self.textField.placeholder = _(placeholerText);
        }
	}
    else if([self isBOOL]){
        //Creates the switch
        _textField.hidden = YES;
        if([model isReadOnly] || self.readOnly){
            self.fixedSize = YES;
            
            __block CKTableViewCellController* bself = self;
            [cell beginBindingsContextByRemovingPreviousBindings];
            self.detailText = [[model value]boolValue] ? @"YES" : @"NO";
            [model.object bind:model.keyPath withBlock:^(id value) {
                bself.detailText = [[model value]boolValue] ? @"YES" : @"NO";
            }];
            [cell endBindingsContext];
        }
        else{
            if(!theSwitch){
                theSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(0,0,100,100)] autorelease];
                theSwitch.tag = 500002;
            }
            
            self.toggleSwitch = theSwitch;
            
            if(self.cellStyle == CKTableViewCellStyleIPadForm){
                [cell.contentView addSubview:self.toggleSwitch];
                [self performLayout];
            }
            else{
                self.accessoryView = self.toggleSwitch;
            }
            
            self.fixedSize = YES;
            [cell beginBindingsContextByRemovingPreviousBindings];
            BOOL bo = [[model value]boolValue];
            [self.toggleSwitch setOn:bo animated:NO];
            [model.object bind:model.keyPath target:self action:@selector(onvalue)];
            [self.toggleSwitch bindEvent:UIControlEventValueChanged target:self action:@selector(onswitch)];
            [cell endBindingsContext];
            
        }
    }
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField.inputAccessoryView = [self navigationToolbar];
    if([self hasNextResponder] == YES){
        self.textField.returnKeyType = UIReturnKeyNext;
    }
    else{
        self.textField.returnKeyType = UIReturnKeyDone;
    }
  
    [self scrollToRow];
    
	[self.tableViewCell beginBindingsContextByRemovingPreviousBindings];
	[textField bindEvent:UIControlEventEditingChanged target:self action:@selector(textFieldChanged:)];
	[self.tableViewCell endBindingsContext];
	
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self didResignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	
	CKProperty* model = self.objectProperty;
    __block CKNSNumberPropertyCellController* bself = self;
    [self.tableViewCell beginBindingsContextByRemovingPreviousBindings];
	[model.object bind:model.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
        CKPropertyExtendedAttributes* attributes = [model extendedAttributes];
        if(attributes.placeholderValue && [attributes.placeholderValue isEqualToNumber:[model value]]){
            if(bself.textField.text != nil){
                bself.textField.text = nil;
            }
        }else{
            NSString* str = [NSValueTransformer transform:value toClass:[NSString class]];
            if(![bself.textField.text isEqualToString:str]){
                bself.textField.text = str;
            }
        }
    }];
	[self.tableViewCell endBindingsContext];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if([self activateNextResponder] == NO){
		[textField resignFirstResponder];
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    CKPropertyExtendedAttributes* attributes = [[self objectProperty]extendedAttributes];
    
    CKInputTextFormatterBlock formatterBlock = self.textInputFormatterBlock;
    if(!formatterBlock){
        formatterBlock = [attributes textInputFormatterBlock];
    }
    
    if(formatterBlock){
        return formatterBlock(textField,range,string);
    }
    
    NSInteger min = [attributes minimumLength];
    NSInteger max = [attributes maximumLength];
	if (range.length>0) {
        if(min >= 0 && range.location < min){
            return NO;
        }
		return YES;
	} else {
        if(max >= 0 && range.location >= max){
            return NO;
        }    
		NSMutableCharacterSet *numberSet = [NSMutableCharacterSet decimalDigitCharacterSet] ;
        
        CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
        switch(descriptor.propertyType){
            case CKClassPropertyDescriptorTypeFloat:
            case CKClassPropertyDescriptorTypeDouble:{
                [numberSet addCharactersInString:@".,"];
            }
        }
                
		return ([string stringByTrimmingCharactersInSet:[numberSet invertedSet]].length > 0);
	}
    return YES;
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
    [self scrollToRowAfterDelay:0];
}

- (BOOL)hasResponder{
	CKClassPropertyDescriptor* descriptor = [self.objectProperty descriptor];
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeChar:
		case CKClassPropertyDescriptorTypeCppBool:
			return NO;
	}
	return ![self.objectProperty isReadOnly];
}

- (UIView*)nextResponder:(UIView*)view{
    if(view == nil){
        return [self.tableViewCell viewWithTag:50000];
    }
	return nil;
}

@end
