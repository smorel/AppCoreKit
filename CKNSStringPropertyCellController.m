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


@implementation CKNSStringPropertyCellController

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStyleValue3;
	return self;
}

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

//pas utiliser load cell mais initCell pour application des styles ...
- (void)initTableViewCell:(UITableViewCell*)cell{
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UITextField *textField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
	textField.tag = 50000;
	textField.borderStyle = UITextBorderStyleNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.clearButtonMode = UITextFieldViewModeAlways;
	textField.delegate = self;
	textField.textAlignment = UITextAlignmentLeft;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
	
	[cell.contentView addSubview:textField];	
}

- (void)layoutCell:(UITableViewCell *)cell{
	UITextField *textField = (UITextField*)[cell.contentView viewWithTag:50000];
	//FIXME : here we could manage layout to fit with value1, value2, subTitle && value3 ...
	//if(self.cellStyle == CKTableViewCellStyleValue3){
		textField.frame = [self value3FrameForCell:cell];
		textField.autoresizingMask = UIViewAutoresizingNone;
	//}
}

- (void)textFieldChanged:(id)value{
	CKObjectProperty* model = self.value;
	[model setValue:value];
	[[NSNotificationCenter defaultCenter]notifyPropertyChange:model];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	CKObjectProperty* model = self.value;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
	
	UITextField *textField = (UITextField*)[cell.contentView viewWithTag:50000];
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[textField bind:@"text" target:self action:@selector(textFieldChanged:)];
	[model.object bind:model.keyPath toObject:textField withKeyPath:@"text"];
	[NSObject endBindingsContext];
	
	NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
	textField.placeholder = _(placeholerText);
	
	if([CKTableViewCellNextResponder needsNextKeyboard:self] == YES){
		textField.returnKeyType = UIReturnKeyNext;
	}
	else{
		textField.returnKeyType = UIReturnKeyDone;
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
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

