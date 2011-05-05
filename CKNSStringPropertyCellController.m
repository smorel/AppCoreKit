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


@implementation CKNSStringPropertyCellController

-(void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self identifier]] autorelease];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	UITextField * textField = [[[UITextField alloc]initWithFrame:CGRectMake(200,0,cell.bounds.size.width - 200,cell.bounds.size.height)]autorelease];
	textField.delegate = self;
	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textField.textAlignment = UITextAlignmentRight;

	cell.accessoryView = textField;
	
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	CKObjectProperty* model = self.value;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
	cell.textLabel.text = _(descriptor.name);
	
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[model.object bind:model.keyPath toObject:cell.accessoryView withKeyPath:@"text"];
	[cell.accessoryView bind:@"text" toObject:model.object withKeyPath:model.keyPath];
	[NSObject endBindingsContext];
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
	[textField resignFirstResponder];
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

@end

