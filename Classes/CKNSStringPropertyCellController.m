//
//  CKNSStringPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


#import "CKNSStringPropertyCellController.h"
#import "CKObjectProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKTableViewCellNextResponder.h"
#import "CKNSValueTransformer+Additions.h"


@implementation CKNSStringPropertyCellController
@synthesize textField = _textField;

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStyleValue3;
	return self;
}

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[_textField release];
	[super dealloc];
}

//pas utiliser load cell mais initCell pour application des styles ...
- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UITextField *txtField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
	txtField.tag = 50000;
	txtField.borderStyle = UITextBorderStyleNone;
	txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	txtField.clearButtonMode = UITextFieldViewModeAlways;
	txtField.delegate = self;
	txtField.textAlignment = UITextAlignmentLeft;
	txtField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.textField = txtField;
}

- (void)layoutCell:(UITableViewCell *)cell{
	[super layoutCell:cell];
	UITextField *textField = (UITextField*)[cell.contentView viewWithTag:50000];
	if(textField){
	//FIXME : here we could manage layout to fit with value1, value2, subTitle && value3 ...
	//if(self.cellStyle == CKTableViewCellStyleValue3){
		textField.frame = [self value3FrameForCell:cell];
		textField.autoresizingMask = UIViewAutoresizingNone;
	//}
	}
}

- (void)textFieldChanged:(id)value{
	CKObjectProperty* model = self.value;
	NSString* strValue = [model value];
	if(value && ![value isKindOfClass:[NSNull class]] &&
	   ![value isEqualToString:strValue]){
		[model setValue:value];
		[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
	}
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[self clearBindingsContext];
	
	CKObjectProperty* model = self.value;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
	
	UITextField *textField = (UITextField*)[cell.contentView viewWithTag:50000];
	if(textField){
		[textField removeFromSuperview];
	}
	cell.detailTextLabel.text = nil;
	
	if([model isReadOnly]){
		[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
		[model.object bind:model.keyPath toObject:cell.detailTextLabel withKeyPath:@"text"];
		[NSObject endBindingsContext];
	}
	else{
		[cell.contentView addSubview:self.textField];
		
		[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
		[model.object bind:model.keyPath toObject:self.textField withKeyPath:@"text"];
		[self.textField bind:@"text" target:self action:@selector(textFieldChanged:)];
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
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self didResignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
	[[self parentTableView] scrollToRowAtIndexPath:self.indexPath 
										   atScrollPosition:UITableViewScrollPositionNone
												   animated:YES];
}


+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	return YES;
}

+ (UIResponder*)responderInView:(UIView*)view{
	UITextField *textField = (UITextField*)[view viewWithTag:50000];
	return textField;
}

@end

