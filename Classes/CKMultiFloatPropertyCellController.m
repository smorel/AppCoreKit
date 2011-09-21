//
//  CKMultiFloatPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKMultiFloatPropertyCellController.h"
#import "CKObjectProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKTableViewCellNextResponder.h"
#import "CKNSValueTransformer+Additions.h"



@implementation CKMultiFloatPropertyCellController
@synthesize multiFloatValue = _multiFloatValue;
@synthesize textFields = _textFields;
@synthesize labels = _labels;
@synthesize namelabels = _namelabels;

-(void)dealloc{
	[_multiFloatValue release];
	[_textFields release];
	[_labels release];
	[_namelabels release];
	[super dealloc];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
	
	self.textFields = [NSMutableDictionary dictionary];
	self.labels = [NSMutableDictionary dictionary];
	self.namelabels = [NSMutableDictionary dictionary];
	
	NSArray* properties = [self.multiFloatValue allPropertyNames];
	int i =0;
	for(NSString* property in properties){
		CGRect labelFrame = CGRectMake(10,44 + (i * 44) - 2,90,44);
		CGRect textFieldFrame = CGRectMake(110,44 + i * 44,cell.contentView.bounds.size.width - 110,44);
		
		UITextField *txtField = [[[UITextField alloc] initWithFrame:textFieldFrame] autorelease];
		txtField.tag = 50000;
		txtField.borderStyle = UITextBorderStyleNone;
		txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		txtField.clearButtonMode = UITextFieldViewModeAlways;
		txtField.delegate = self;
		txtField.keyboardType = UIKeyboardTypeDecimalPad;
		txtField.textAlignment = UITextAlignmentLeft;
		txtField.autocorrectionType = UITextAutocorrectionTypeNo;
		txtField.autoresizingMask = UIViewAutoresizingNone;
		NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",property];
		txtField.placeholder = _(placeholerText);
		[_textFields setObject:txtField forKey:property];
		
		UILabel* namelabel = [[[UILabel alloc]initWithFrame:labelFrame]autorelease];
		namelabel.text = property;
		namelabel.textAlignment = UITextAlignmentRight;
		namelabel.backgroundColor = [UIColor clearColor];
		namelabel.font = [UIFont boldSystemFontOfSize:17];
		[cell.contentView addSubview:namelabel];
		[_namelabels setObject:namelabel forKey:property];
		
		
		UILabel* label = [[[UILabel alloc]initWithFrame:textFieldFrame]autorelease];
		label.backgroundColor = [UIColor clearColor];
		txtField.autoresizingMask = UIViewAutoresizingNone;
		[_labels setObject:label forKey:property];
		++i;
	}
	
	//introspect self.multiFloatValue and create widgets
	//bindEachWidgets to update the properties respectivelly and call [self valueChanged];
}

- (void)layoutCell:(UITableViewCell *)cell{
	CGRect textFrame = [self value3TextFrameForCell:cell];
	
	int i =0 ;
	NSArray* properties = [self.multiFloatValue allPropertyNames];
	for(NSString* property in properties){
        CGFloat width = cell.contentView.frame.size.width;
        CGFloat detailX = textFrame.origin.x + textFrame.size.width + 10;
        CGFloat detailWidth = width - detailX - 10;
		UILabel *label = [_labels objectForKey:property];
		UITextField *txtField = [_textFields objectForKey:property];
		CGRect frame = CGRectMake(detailX,44 + i * 44,detailWidth,44);
		label.frame = frame;
		txtField.frame = frame;
		
		UILabel *namelabel = [_namelabels objectForKey:property];
		CGRect nameFrame = CGRectMake(10,frame.origin.y - 1,detailX - 20,44);
		namelabel.frame = nameFrame;
		++i;
	}
	
	cell.textLabel.frame = CGRectMake(10,10,cell.contentView.frame.size.width - 20,44);
	cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
}

- (void)textFieldChanged:(id)value{
	NSArray* properties = [self.multiFloatValue allPropertyNames];
	for(NSString* property in properties){
		UITextField *txtField = [_textFields objectForKey:property];
		CGFloat f = [txtField.text floatValue];
		[self.multiFloatValue setValue:[NSNumber numberWithFloat:f] forKeyPath:property];
		[self valueChanged];
	}
}

- (void)unbind{
	[self clearBindingsContext];
}

- (void)rebind{
	CKObjectProperty* property = (CKObjectProperty*)self.value;
	if([property isReadOnly] || self.readOnly){
		[self beginBindingsContextByRemovingPreviousBindings];
		NSArray* properties = [self.multiFloatValue allPropertyNames];
		for(NSString* property in properties){
			UILabel *label = [_labels objectForKey:property];
			[self.multiFloatValue bind:property toObject:label withKeyPath:@"text"];
		}
		[self endBindingsContext];
	}
	else{
		[self beginBindingsContextByRemovingPreviousBindings];
		NSArray* properties = [self.multiFloatValue allPropertyNames];
		for(NSString* property in properties){
			UITextField *txtField = [_textFields objectForKey:property];
			[self.multiFloatValue bind:property toObject:txtField withKeyPath:@"text"];
		}
		[self endBindingsContext];
	}	
}

- (void)setupCell:(UITableViewCell *)cell {
	[self unbind];
	[super setupCell:cell];
	
	NSArray* properties = [self.multiFloatValue allPropertyNames];
	for(NSString* property in properties){
		UILabel *label = [_labels objectForKey:property];
		[label removeFromSuperview];
		UITextField *txtField = [_textFields objectForKey:property];
		[txtField removeFromSuperview];
	}
	
	CKObjectProperty* property = (CKObjectProperty*)self.value;
	if([property isReadOnly] || self.readOnly){
		NSArray* properties = [self.multiFloatValue allPropertyNames];
		for(NSString* property in properties){
			UILabel *label = [_labels objectForKey:property];
			[self.tableViewCell.contentView addSubview:label];
		}
	}
	else{
		NSArray* properties = [self.multiFloatValue allPropertyNames];
		for(NSString* property in properties){
			UITextField *txtField = [_textFields objectForKey:property];
			[self.tableViewCell.contentView addSubview:txtField];
		}
	}	
	
	[self rebind];
	
	cell.textLabel.text = [property name];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)didSelectRow{
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

- (void)valueChanged{
}

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
	[self rebind];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if([CKTableViewCellNextResponder activateNextResponderFromController:self] == NO){
		[textField resignFirstResponder];
	}
	return YES;
}

//- (void)textFieldChanged:(id)value

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	//[self textFieldChanged:textField.text];
	return YES;
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
	[[self parentTableView] scrollToRowAtIndexPath:self.indexPath 
								  atScrollPosition:UITableViewScrollPositionNone 
										  animated:YES];
}

@end