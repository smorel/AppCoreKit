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
#import "CKNSNotificationCenter+Edition.h"
#import "CKTableViewCellNextResponder.h"
#import "CKNSValueTransformer+Additions.h"

#define TextEditTag 1
#define SwitchTag 2
#define LabelTag 3

@implementation CKNSNumberPropertyCellController
@synthesize textField = _textField;
@synthesize toggleSwitch = _toggleSwitch;

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
	return self;
}

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[_textField release];
	[_toggleSwitch release];
	[super dealloc];
}

- (void)onswitch{
	CKObjectProperty* model = self.value;
	UISwitch* s = (UISwitch*)[self.tableViewCell viewWithTag:SwitchTag];
	[model setValue:[NSNumber numberWithBool:s.on]];
	[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
}

- (void)onvalue{
	CKObjectProperty* model = self.value;
	BOOL bo = [[model value] boolValue];
	
	UISwitch* s = (UISwitch*)[self.tableViewCell viewWithTag:SwitchTag];
	[s setOn:bo animated:YES];
}

- (void)textFieldChanged:(id)value{
	CKObjectProperty* model = self.value;
	NSNumber* number = (NSNumber*)[self.value value];
	NSNumber* newNumber = [NSValueTransformer transform:self.textField.text toClass:[NSNumber class]];
	if(newNumber == nil){
		[model setValue:[NSNumber numberWithInt:0]];
		[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
	}
	else if(![number isEqualToNumber:newNumber]){
		[model setValue:newNumber];
		[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
	}
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UITextField *txtField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
	txtField.tag = 50000;
	txtField.borderStyle = UITextBorderStyleNone;
	txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	txtField.clearButtonMode = UITextFieldViewModeAlways;
	txtField.delegate = self;
	txtField.keyboardType = UIKeyboardTypeDecimalPad;
	txtField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            txtField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            txtField.textAlignment = UITextAlignmentRight;
        }  
        else{
            txtField.textColor = [UIColor blackColor];
            txtField.textAlignment = UITextAlignmentLeft;
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

			if([model isReadOnly]){
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
			if([model isReadOnly]){
				[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
				[model.object bind:model.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
				[NSObject endBindingsContext];
			}
			else{
                
                if(self.cellStyle == CKTableViewCellStyleValue3 ||
                   ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad && self.cellStyle == CKTableViewCellStylePropertyGrid)){
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

- (void)layoutCell:(UITableViewCell *)cell{
	[super layoutCell:cell];
	UITextField *textField = (UITextField*)[cell.contentView viewWithTag:50000];
	if(textField){
		if(self.cellStyle == CKTableViewCellStyleValue3){
			textField.frame = [self value3DetailFrameForCell:cell];
			textField.autoresizingMask = UIViewAutoresizingNone;
		}
        else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
			textField.frame = [self propertyGridDetailFrameForCell:cell];
			textField.autoresizingMask = UIViewAutoresizingNone;
		}
	}
	
	UISwitch* s = (UISwitch*)[cell viewWithTag:SwitchTag];
	if(s){
		if(self.cellStyle == CKTableViewCellStyleValue3){
            CGRect switchFrame = [self value3DetailFrameForCell:cell];
			CGFloat height = cell.bounds.size.height;
			CGRect rectForSwitch = CGRectMake(switchFrame.origin.x,(height/ 2.0) - (s.frame.size.height / 2.0),s.frame.size.width,s.frame.size.height);
			s.frame = rectForSwitch;
		}
        else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
			CGRect switchFrame = [self propertyGridDetailFrameForCell:cell];
			CGFloat height = cell.bounds.size.height;
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                //align right
                CGRect rectForSwitch = CGRectMake(switchFrame.origin.x,(height/ 2.0) - (s.frame.size.height / 2.0),s.frame.size.width,s.frame.size.height);
                s.frame = rectForSwitch;
            }
            //For iphone its an accessory view
		}
	}
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44)];
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateCell:cell withParams:params animated:animated];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self beginBindingsContextByRemovingPreviousBindings];
	[textField bindEvent:UIControlEventEditingChanged target:self action:@selector(textFieldChanged:)];
	[self endBindingsContext];
	
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self didResignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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
