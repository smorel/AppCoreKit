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
        self.editable = NO;
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
	
	UITextField *textField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
	textField.borderStyle = UITextBorderStyleNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	textField.textColor = [UIColor blueTextColor];
	cell.accessoryView = textField;
}

- (id)performStandardLayout:(CKTextFieldCellController*)controller{
    UITableViewCell* cell = controller.tableViewCell;
	UITextField *textField = (UITextField*)cell.accessoryView;
	//update accessory view frame
	CGRect frame = CGRectIntegral(CGRectMake(0, 0, cell.bounds.size.width * (2.0f / 3.5f), cell.bounds.size.height));
	textField.frame = frame;
	cell.accessoryView.frame = frame;
    return (id)nil;
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
	NSAssert([self.parentController isKindOfClass:[CKTableViewController class]],@"invalid parent controller class");
	CKTableViewController* tableViewController = (CKTableViewController*)self.parentController;
	[tableViewController.tableView scrollToRowAtIndexPath:self.indexPath 
										   atScrollPosition:UITableViewScrollPositionNone 
												   animated:YES];
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}

@end
