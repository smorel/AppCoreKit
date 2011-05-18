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

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

//pas utiliser load cell mais initCell pour application des styles ...
- (void)initTableViewCell:(UITableViewCell*)cell{
	_accessoryViewSizeRatio = 2.0 / 3.0;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UITextField *textField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
	textField.borderStyle = UITextBorderStyleNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.clearButtonMode = UITextFieldViewModeAlways;
	textField.delegate = self;
	textField.textAlignment = UITextAlignmentLeft;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	
	cell.accessoryView = textField;	
}

- (void)layoutCell:(UITableViewCell *)cell{
	UITextField *textField = (UITextField*)cell.accessoryView;
	//update accessory view frame
	CGRect frame = CGRectIntegral(CGRectMake(0, 0, cell.bounds.size.width * (2.0f / 3.5f), cell.bounds.size.height));
	textField.frame = frame;
	cell.accessoryView.frame = frame;
	
	NSLog(@"cell size : %f %f textField size : %f %f accessoryView frame : %f %f",
		  cell.bounds.size.width,cell.bounds.size.height,
		  textField.bounds.size.width,textField.bounds.size.height,
		  cell.accessoryView.bounds.size.width,cell.accessoryView.bounds.size.height);
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
	
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[cell.accessoryView bind:@"text" target:self action:@selector(textFieldChanged:)];
	[model.object bind:model.keyPath toObject:cell.accessoryView withKeyPath:@"text"];
	[NSObject endBindingsContext];
	
	UITextField *textField = (UITextField*)cell.accessoryView;
	NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
	textField.placeholder = _(placeholerText);
	
	if([CKTableViewCellNextResponder needsNextKeyboard:self] == YES){
		textField.returnKeyType = UIReturnKeyNext;
	}
	else{
		textField.returnKeyType = UIReturnKeyDone;
	}
}

+ (NSValue*)rowSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,44)];
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateCell:cell withParams:params animated:animated];
}

+ (CKTableViewCellFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKTableViewCellFlagNone;
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
	[self.parentController.tableView scrollToRowAtIndexPath:self.indexPath 
										   atScrollPosition:UITableViewScrollPositionNone 
												   animated:YES];
}


+ (BOOL)hasAccessoryResponderWithValue:(id)object{
	return YES;
}

@end

