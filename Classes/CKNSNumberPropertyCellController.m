//
//  CKNSNumberPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSNumberPropertyCellController.h"
#import "CKObjectProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellNextResponder.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKUIView+Positioning.h"

#define TextEditTag 1
#define SwitchTag 2
#define LabelTag 3

@interface CKNSNumberPropertyCellController()
@property (nonatomic,retain,readwrite) UITextField* textField;
@property (nonatomic,retain,readwrite) UITextField* toggleSwitch;
@end

@implementation CKNSNumberPropertyCellController
@synthesize textField = _textField;
@synthesize toggleSwitch = _toggleSwitch;

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[_textField release];
	[_toggleSwitch release];
	[super dealloc];
}

- (void)onswitch{
	UISwitch* s = (UISwitch*)[self.tableViewCell viewWithTag:SwitchTag];
    [self setValueInObjectProperty:[NSNumber numberWithBool:s.on]];
}

- (void)onvalue{
	CKObjectProperty* model = self.value;
	BOOL bo = [[model value] boolValue];
	
	UISwitch* s = (UISwitch*)[self.tableViewCell viewWithTag:SwitchTag];
	[s setOn:bo animated:YES];
}

- (void)textFieldChanged:(id)thevalue{
    CKObjectProperty* property = (CKObjectProperty*)self.value;
	NSNumber* number = (NSNumber*)[property value];
	NSNumber* newNumber = [NSValueTransformer transform:self.textField.text toClass:[NSNumber class]];
	if(newNumber == nil){
        [self setValueInObjectProperty:[NSNumber numberWithInt:0]];
	}
	else if(![number isEqualToNumber:newNumber]){
        [self setValueInObjectProperty:newNumber];
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
    
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            _textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            _textField.textAlignment = UITextAlignmentRight;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        }  
        else{
            _textField.textColor = [UIColor blackColor];
            _textField.textAlignment = UITextAlignmentLeft;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }
    }  
    
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid){
        _textField.autoresizingMask = UIViewAutoresizingNone;
    }
    
    UISwitch *theSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(0,0,100,100)] autorelease];
    self.toggleSwitch = theSwitch;
    
    _toggleSwitch.hidden = YES; //will get displayed in setup depending on the model
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad ||
       ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone && self.cellStyle == CKTableViewCellStyleValue3)){
        [cell.contentView addSubview:self.toggleSwitch];
    }
    else{
        cell.accessoryView = self.toggleSwitch;
    }

    _toggleSwitch.tag = SwitchTag;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[self clearBindingsContext];
    
    //In Case view is reused
    self.textField = (UITextField*)[cell.contentView viewWithTag:50000];
	_textField.delegate = self;
    self.toggleSwitch = (UISwitch*)[cell viewWithTag:SwitchTag];
	
	CKObjectProperty* model = self.value;
	
	//reset the view
	cell.detailTextLabel.text = nil;
	
	//build and setup the view
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
	
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeInt:
		case CKClassPropertyDescriptorTypeShort:
		case CKClassPropertyDescriptorTypeLong:
		case CKClassPropertyDescriptorTypeLongLong:
		case CKClassPropertyDescriptorTypeUnsignedChar:
		case CKClassPropertyDescriptorTypeUnsignedInt:
		case CKClassPropertyDescriptorTypeUnsignedShort:
		case CKClassPropertyDescriptorTypeUnsignedLong:
		case CKClassPropertyDescriptorTypeUnsignedLongLong:
		case CKClassPropertyDescriptorTypeFloat:
		case CKClassPropertyDescriptorTypeDouble:{
			cell.accessoryType = UITableViewCellAccessoryNone;

            _toggleSwitch.hidden = YES;
			if([model isReadOnly] || self.readOnly){
                self.fixedSize = YES;
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				[model.object bind:model.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
				[NSObject endBindingsContext];
                _textField.hidden = YES;
			}
			else{
				if(self.cellStyle == CKTableViewCellStylePropertyGrid
                   && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                        self.fixedSize = YES;
                }
                else{
                    self.fixedSize = NO;
                }
                _textField.hidden = NO;
				
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				[model.object bind:model.keyPath toObject:self.textField withKeyPath:@"text"];
				[NSObject endBindingsContext];
				
				NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
				self.textField.placeholder = _(placeholerText);
			}
	
			break;
		}
		case CKClassPropertyDescriptorTypeChar:
		case CKClassPropertyDescriptorTypeCppBool:{
            _textField.hidden = YES;
			if([model isReadOnly] || self.readOnly){
                self.fixedSize = YES;
                _toggleSwitch.hidden = YES;
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				[model.object bind:model.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
				[NSObject endBindingsContext];
			}
			else{
                self.fixedSize = YES;
                _toggleSwitch.hidden = NO;
				
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				BOOL bo = [[model value]boolValue];
				[self.toggleSwitch setOn:bo animated:NO];
				[model.object bind:model.keyPath target:self action:@selector(onvalue)];
				[self.toggleSwitch bindEvent:UIControlEventTouchUpInside target:self action:@selector(onswitch)];
				[NSObject endBindingsContext];
			}
			break;
		}
	}	
}

- (id)performStandardLayout:(CKNSNumberPropertyCellController*)controller{
    UITableViewCell* cell = controller.tableViewCell;
    
	UISwitch* s = [controller.toggleSwitch superview] ? controller.toggleSwitch : nil;
    CGFloat savedComponentRatio = self.componentsRatio;
    if(s && controller.cellStyle == CKTableViewCellStylePropertyGrid
       && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        controller.componentsRatio = 0.3;
    }
    
	[super performStandardLayout:controller];
    
	UITextField *textField = [controller.textField superview] ? controller.textField : nil;
	if(textField){
		if(controller.cellStyle == CKTableViewCellStyleValue3
           || controller.cellStyle == CKTableViewCellStylePropertyGrid){
            CGFloat realWidth = cell.contentView.frame.size.width;
            CGFloat textFieldX = (cell.textLabel.frame.origin.x + cell.textLabel.frame.size.width) + self.componentsSpace;
            CGFloat textFieldWidth = realWidth - self.contentInsets.right - textFieldX;
			textField.frame = CGRectIntegral(CGRectMake(textFieldX,self.contentInsets.top,textFieldWidth,textField.font.lineHeight));
            
            //align textLabel on y
            CGFloat txtFieldCenter = textField.y + (textField.height / 2.0);
            CGFloat txtLabelHeight = cell.textLabel.height;
            CGFloat txtLabelY = txtFieldCenter - (txtLabelHeight / 2.0);
            cell.textLabel.y = txtLabelY;
		}
        else if(controller.cellStyle == CKTableViewCellStyleSubtitle2){
            textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            CGFloat x = cell.textLabel.x;
            CGRect textFrame = cell.textLabel.frame;
            CGFloat width = cell.contentView.width - x - 10;
            
			textField.frame = CGRectIntegral(CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10,width,(textField.font.lineHeight + 10)));
        }
	}
    
	if(s){
		if(controller.cellStyle == CKTableViewCellStyleValue3){
            CGRect switchFrame = [self value3DetailFrameForCell:cell];
			CGFloat height = cell.bounds.size.height;
			CGRect rectForSwitch = CGRectMake(switchFrame.origin.x,(height/ 2.0) - (s.frame.size.height / 2.0),s.frame.size.width,s.frame.size.height);
			s.frame = CGRectIntegral(rectForSwitch);
		}
        else if(controller.cellStyle == CKTableViewCellStylePropertyGrid){
			CGFloat height = MAX(44,controller.tableViewCell.textLabel.frame.size.height);
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                //align right
                CGRect rectForSwitch = CGRectMake(controller.tableViewCell.textLabel.frame.origin.x + controller.tableViewCell.textLabel.frame.size.width + 10,
                                                  (height/ 2.0) - (s.frame.size.height / 2.0),s.frame.size.width,s.frame.size.height);
                s.frame = CGRectIntegral(rectForSwitch);
            }
            //For iphone its an accessory view
		}
        
        controller.componentsRatio = savedComponentRatio;
	}
    return (id)nil;
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
    CKNSNumberPropertyCellController* staticController = (CKNSNumberPropertyCellController*)[params staticController];
    
	UISwitch* s = (UISwitch*)[staticController.tableViewCell viewWithTag:SwitchTag];
	UITextField *textField = (UITextField*)[staticController.tableViewCell viewWithTag:50000];
        
    CGFloat bottomTextField = textField ? (textField.frame.origin.y + textField.frame.size.height) : 0;
    CGFloat bottomSwitch = s ? (s.frame.origin.y + s.frame.size.height) : 0;
    CGFloat bottomTextLabel = staticController.tableViewCell.textLabel.frame.origin.y + staticController.tableViewCell.textLabel.frame.size.height;
    CGFloat bottomDetailTextLabel = [staticController.tableViewCell.detailTextLabel text] ? (staticController.tableViewCell.detailTextLabel.frame.origin.y + staticController.tableViewCell.detailTextLabel.frame.size.height) : 0;
    CGFloat maxHeight = MAX(bottomTextField,MAX(bottomSwitch,MAX(bottomTextLabel,bottomDetailTextLabel))) + staticController.contentInsets.bottom;
    return [NSValue valueWithCGSize:CGSizeMake(100,maxHeight)];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField.inputAccessoryView = [self navigationToolbar];
    if([CKTableViewCellNextResponder needsNextKeyboard:self] == YES){
        self.textField.returnKeyType = UIReturnKeyNext;
    }
    else{
        self.textField.returnKeyType = UIReturnKeyDone;
    }
  
    [self scrollToRow];
    
	[self beginBindingsContextByRemovingPreviousBindings];
	[textField bindEvent:UIControlEventEditingChanged target:self action:@selector(textFieldChanged:)];
	[self endBindingsContext];
	
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self didResignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	
	CKObjectProperty* model = self.value;
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[model.object bind:model.keyPath toObject:self.textField withKeyPath:@"text"];
	[NSObject endBindingsContext];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if([CKTableViewCellNextResponder activateNextResponderFromController:self] == NO){
		[textField resignFirstResponder];
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    CKObjectPropertyMetaData* metaData = [[self objectProperty]metaData];
    NSInteger min = [metaData.options minimumLength];
    NSInteger max = [metaData.options maximumLength];
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

+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	CKObjectProperty* model = object;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeChar:
		case CKClassPropertyDescriptorTypeCppBool:
			return NO;
	}
	return ![model isReadOnly];
}

+ (UIView*)responderInView:(UIView*)view{
	UITextField *textField = (UITextField*)[view viewWithTag:50000];
	return textField;
}

@end
