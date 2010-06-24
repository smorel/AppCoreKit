//
//  CKTextFieldCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-24.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKTextFieldCellController.h"

@interface CKTextFieldCellController ()

@property (nonatomic, readwrite, retain) UITextField *textField;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, assign) CGPoint tableContentOffset;

@end

//

@implementation CKTextFieldCellController

@synthesize textField = _textField;
@synthesize placeholder = _placeholder;
@synthesize tableContentOffset = _tableContentOffset;

- (id)initWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder {
	if (self = [super initWithText:title]) {
		self.value = value;
		self.placeholder = placeholder;
		self.selectable = NO;
	}
	return self;
}

- (void)dealloc {
	self.textField = nil;
	self.placeholder = nil;
	[super dealloc];
}

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:UITableViewCellStyleDefault];
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	CGFloat offset = self.text ? (cell.contentView.bounds.size.width/2.55) : 20;
	CGRect frame = CGRectIntegral(UIEdgeInsetsInsetRect(cell.contentView.bounds, UIEdgeInsetsMake(10, 10 + offset, 10, 10)));
	self.textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
	self.textField.delegate = self;
	self.textField.borderStyle = UITextBorderStyleNone;
	self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	self.textField.tag = 1000;
	
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];

	cell.accessoryView = self.textField;
	self.textField.placeholder = self.placeholder;
	self.textField.text = self.value;
}

#pragma mark UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.tableContentOffset = self.parentController.tableView.contentOffset;
	[self.parentController.tableView scrollToRowAtIndexPath:self.indexPath 
										   atScrollPosition:UITableViewScrollPositionTop 
												   animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self.parentController.tableView setContentOffset:self.tableContentOffset animated:YES];
	self.value = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

@end
