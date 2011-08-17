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

#define TextEditTag 1
#define SwitchTag 2
#define LabelTag 3

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

- (void)textFieldChanged:(id)value{
	NSNumber* number = (NSNumber*)[self.value value];
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
	txtField.tag = 50000;
	txtField.borderStyle = UITextBorderStyleNone;
	txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
	txtField.delegate = self;
	txtField.keyboardType = UIKeyboardTypeDecimalPad;
	txtField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            txtField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            txtField.textAlignment = UITextAlignmentRight;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        }  
        else{
            txtField.textColor = [UIColor blackColor];
            txtField.textAlignment = UITextAlignmentLeft;
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }
    }  
    
	self.textField = txtField;
	
	UISwitch *theSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(0,0,100,100)] autorelease];
	theSwitch.tag = SwitchTag;
	self.toggleSwitch = theSwitch;
	//creates textfiled and switch here and store them as property for stylesheets ...
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[self clearBindingsContext];
	
	CKObjectProperty* model = self.value;
	
	//reset the view
	cell.accessoryView = nil;
	UITextField *textField = (UITextField*)[cell.contentView viewWithTag:50000];
	if(textField){
		[textField removeFromSuperview];
	}
	UISwitch* s = (UISwitch*)[cell viewWithTag:SwitchTag];
	if(s){
		[s removeFromSuperview];
	}
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

			if([model isReadOnly] || self.readOnly){
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				[model.object bind:model.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
				[NSObject endBindingsContext];
			}
			else{
				
				[cell.contentView addSubview:self.textField];
				
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				[model.object bind:model.keyPath toObject:self.textField withKeyPath:@"text"];
				[NSObject endBindingsContext];
				
				NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
				self.textField.placeholder = _(placeholerText);
				
				if([CKTableViewCellNextResponder needsNextKeyboard:self] == YES){
					self.textField.returnKeyType = UIReturnKeyNext;
				}
				else{
					self.textField.returnKeyType = UIReturnKeyDone;
				}
			}
	
			break;
		}
		case CKClassPropertyDescriptorTypeChar:
		case CKClassPropertyDescriptorTypeCppBool:{
			if([model isReadOnly] || self.readOnly){
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				[model.object bind:model.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
				[NSObject endBindingsContext];
			}
			else{
                
                if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad ||
                   ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone && self.cellStyle == CKTableViewCellStyleValue3)){
					[cell.contentView addSubview:self.toggleSwitch];
				}
				else{
					cell.accessoryView = self.toggleSwitch;
				}
				
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
    
	UISwitch* s = (UISwitch*)[cell viewWithTag:SwitchTag];
    CGFloat savedComponentRatio = self.componentsRatio;
    if(s && controller.cellStyle == CKTableViewCellStylePropertyGrid
       && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        controller.componentsRatio = 0.3;
    }
    
	[super performStandardLayout:controller];
    
	UITextField *textField = (UITextField*)[cell.contentView viewWithTag:50000];
	if(textField){
		if(controller.cellStyle == CKTableViewCellStyleValue3
           || controller.cellStyle == CKTableViewCellStylePropertyGrid){
            CGFloat realWidth = cell.contentView.frame.size.width;
            CGFloat textFieldX = (cell.textLabel.frame.origin.x + cell.textLabel.frame.size.width) + 10;
            CGFloat textFieldWidth = realWidth - 10 - textFieldX;
			textField.frame = CGRectIntegral(CGRectMake(textFieldX,11,textFieldWidth,textField.font.lineHeight));
			textField.autoresizingMask = UIViewAutoresizingNone;
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
    CGFloat maxHeight = MAX(bottomTextField,MAX(bottomSwitch,MAX(bottomTextLabel,bottomDetailTextLabel))) + 10;
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
	[[self parentTableView] scrollToRowAtIndexPath:self.indexPath 
                                  atScrollPosition:UITableViewScrollPositionNone 
                                          animated:YES];
    
	[self beginBindingsContextByRemovingPreviousBindings];
	[textField bindEvent:UIControlEventEditingChanged target:self action:@selector(textFieldChanged:)];
	[self endBindingsContext];
	
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self didResignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	
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
	//TODO : filter numbers
	return YES;
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
	[[self parentTableView] scrollToRowAtIndexPath:self.indexPath 
                                  atScrollPosition:UITableViewScrollPositionNone 
                                          animated:YES];
}

+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	CKObjectProperty* model = object;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeChar:
		case CKClassPropertyDescriptorTypeCppBool:
			return NO;
	}
	return YES;
}

+ (UIResponder*)responderInView:(UIView*)view{
	UITextField *textField = (UITextField*)[view viewWithTag:50000];
	return textField;
}

@end
