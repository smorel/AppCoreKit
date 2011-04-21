//
//  CKTextFieldCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-24.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKTextFieldCellController.h"
#import "CKUIKeyboardInformation.h"
#import "CKUIColorAdditions.h"
#import "CKConstants.h"

@interface CKTextFieldCellController ()

@property (nonatomic, retain) NSString *placeholder;

@end

//

@implementation CKTextFieldCellController

@synthesize placeholder = _placeholder;
@synthesize secureTextEntry = _secureTextEntry;

- (id)initWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder {
	if (self = [super initWithText:title]) {
		self.value = value;
		self.placeholder = placeholder;
		self.selectable = NO;
	}
	return self;
}

- (void)dealloc {
	self.placeholder = nil;
	[super dealloc];
}


- (void)initTableViewCell:(UITableViewCell*)cell{
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	UITableView *tableView = self.parentController.tableView;
	CGFloat width = tableView.bounds.size.width - ((tableView.style == UITableViewStylePlain) ? 20 : 40);
	CGFloat offset = self.text ? (width/2.55) : 0;
	CGRect frame = CGRectIntegral(CGRectMake(0, 10, width - offset, self.rowHeight - 20));
	UITextField *textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
	textField.borderStyle = UITextBorderStyleNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	textField.textColor = [UIColor blueTextColor];
	cell.accessoryView = textField;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];

	UITextField *textField = (UITextField *)cell.accessoryView;
	textField.delegate = self;
	textField.text = self.value;
	textField.placeholder = self.placeholder;
}

- (void)cellDidAppear:(UITableViewCell *)cell {
	[super cellDidAppear:cell];
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.value = textField.text;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([self.target respondsToSelector:self.action]) [self.target performSelector:self.action withObject:self];
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

#pragma mark Value

- (void)valueChanged:(id)sender {
	self.value = ((UITextField *)sender).text;
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
	[self.parentController.tableView scrollToRowAtIndexPath:self.indexPath 
										   atScrollPosition:UITableViewScrollPositionNone 
												   animated:YES];
}

@end
