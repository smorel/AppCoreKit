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

#define BASE_TAG 8723

@implementation CKMultiFloatPropertyCellController
@synthesize multiFloatValue = _multiFloatValue;

-(void)dealloc{
	[_multiFloatValue release];
	[super dealloc];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
	
	NSArray* properties = [[[self.multiFloatValue allPropertyNames]reverseObjectEnumerator]allObjects];
	int i =0;
	for(NSString* property in properties){
		CGRect labelFrame = CGRectMake(10,44 + (i * 44) - 2,90,44);
		CGRect textFieldFrame = CGRectMake(110,44 + i * 44,cell.contentView.bounds.size.width - 110,44);
		
		UITextField *txtField = [[[UITextField alloc] initWithFrame:textFieldFrame] autorelease];
        txtField.autoresizingMask = UIViewAutoresizingNone;
		txtField.tag = BASE_TAG + (i*3) + 0;
		txtField.borderStyle = UITextBorderStyleNone;
		txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		txtField.clearButtonMode = UITextFieldViewModeAlways;
		txtField.keyboardType = UIKeyboardTypeDecimalPad;
		txtField.textAlignment = UITextAlignmentLeft;
		txtField.autocorrectionType = UITextAutocorrectionTypeNo;
		txtField.autoresizingMask = UIViewAutoresizingNone;
		NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",property];
		txtField.placeholder = _(placeholerText);
		[cell.contentView addSubview:txtField];
		
		UILabel* namelabel = [[[UILabel alloc]initWithFrame:labelFrame]autorelease];
        namelabel.autoresizingMask = UIViewAutoresizingNone;
        namelabel.tag = BASE_TAG + (i*3) + 1;
		namelabel.text = property;
		namelabel.textAlignment = UITextAlignmentRight;
		namelabel.backgroundColor = [UIColor clearColor];
		namelabel.font = [UIFont boldSystemFontOfSize:17];
		[cell.contentView addSubview:namelabel];
		
		
		UILabel* label = [[[UILabel alloc]initWithFrame:textFieldFrame]autorelease];
        label.autoresizingMask = UIViewAutoresizingNone;
		label.backgroundColor = [UIColor clearColor];
        label.tag = BASE_TAG + (i*3) + 2;
		[cell.contentView addSubview:label];
		++i;
	}
}

- (void)layoutCell:(UITableViewCell *)cell{
	int i =0 ;
	NSArray* properties = [[[self.multiFloatValue allPropertyNames]reverseObjectEnumerator]allObjects];
	for(NSString* property in properties){
		UITextField *txtField = (UITextField*)[cell.contentView viewWithTag:BASE_TAG + (i*3) + 0];
		UILabel *namelabel = (UILabel*)[cell.contentView viewWithTag:BASE_TAG + (i*3) + 1];
		UILabel *label = (UILabel*)[cell.contentView viewWithTag:BASE_TAG + (i*3) + 2];
        
        CGFloat width = cell.contentView.frame.size.width;
        CGFloat detailX = width / 2.0;
        CGFloat detailWidth = width - detailX - 10;
        
        txtField.autoresizingMask = UIViewAutoresizingNone;
        label.autoresizingMask = UIViewAutoresizingNone;
        
		CGRect frame = CGRectMake(detailX,44 + i * 44,detailWidth,44);
		label.frame = frame;
		txtField.frame = frame;
		
        namelabel.autoresizingMask = UIViewAutoresizingNone;
		CGRect nameFrame = CGRectMake(10,frame.origin.y - 1,detailX - 20,44);
		namelabel.frame = nameFrame;
		++i;
	}
	
	cell.textLabel.frame = CGRectMake(10,10,cell.contentView.frame.size.width - 20,44);
	cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
}

- (void)textFieldChanged:(id)value{
	NSArray* properties = [[[self.multiFloatValue allPropertyNames]reverseObjectEnumerator]allObjects];
	int i =0 ;
	for(NSString* property in properties){
		UITextField *txtField = (UITextField*)[self.tableViewCell.contentView viewWithTag:BASE_TAG + (i*3) + 0];
		CGFloat f = [txtField.text floatValue];
		[self.multiFloatValue setValue:[NSNumber numberWithFloat:f] forKeyPath:property];
		[self valueChanged];
		++i;
	}
}

- (void)unbind{
	[self clearBindingsContext];
}

- (void)propertyChanged{
    //Implement in subClass : set wrapper value;
}

- (void)rebind{
    [self beginBindingsContextByRemovingPreviousBindings];
	CKObjectProperty* property = (CKObjectProperty*)self.value;
    [property.object bind:property.keyPath target:self action:@selector(propertyChanged)];
	if([property isReadOnly] || self.readOnly){
        NSArray* properties = [[[self.multiFloatValue allPropertyNames]reverseObjectEnumerator]allObjects];
        int i =0 ;
		for(NSString* property in properties){
            UILabel *label = (UILabel*)[self.tableViewCell.contentView viewWithTag:BASE_TAG + (i*3) + 2];
			[self.multiFloatValue bind:property toObject:label withKeyPath:@"text"];
            ++i;
		}
	}
	else{
        NSArray* properties = [[[self.multiFloatValue allPropertyNames]reverseObjectEnumerator]allObjects];
        int i =0 ;
		for(NSString* property in properties){
            UITextField *txtField = (UITextField*)[self.tableViewCell.contentView viewWithTag:BASE_TAG + (i*3) + 0];
			[self.multiFloatValue bind:property toObject:txtField withKeyPath:@"text"];
            ++i;
		}
	}	
    [self endBindingsContext];
}

- (void)setupCell:(UITableViewCell *)cell {
	[self unbind];
	[super setupCell:cell];
    [self propertyChanged];
	
	CKObjectProperty* property = (CKObjectProperty*)self.value;
	if([property isReadOnly] || self.readOnly){
        NSArray* properties = [[[self.multiFloatValue allPropertyNames]reverseObjectEnumerator]allObjects];
        int i =0 ;
		for(NSString* property in properties){
            UILabel *label = (UILabel*)[self.tableViewCell.contentView viewWithTag:BASE_TAG + (i*3) + 2];
            label.hidden = NO;
            UITextField *txtField = (UITextField*)[self.tableViewCell.contentView viewWithTag:BASE_TAG + (i*3) + 0];
            txtField.hidden = YES;
            txtField.delegate = nil;
            ++i;
		}
	}
	else{
        NSArray* properties = [[[self.multiFloatValue allPropertyNames]reverseObjectEnumerator]allObjects];
        int i =0 ;
		for(NSString* property in properties){
            UILabel *label = (UILabel*)[self.tableViewCell.contentView viewWithTag:BASE_TAG + (i*3) + 2];
            label.hidden = YES;
            UITextField *txtField = (UITextField*)[self.tableViewCell.contentView viewWithTag:BASE_TAG + (i*3) + 0];
            txtField.hidden = NO;
            txtField.delegate = self;
            ++i;
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self didResignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
    [self scrollToRowAfterDelay:0];
}

@end