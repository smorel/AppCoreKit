//
//  CKStandardCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKStandardCellController.h"

@interface CKStandardCellController ()

@property (nonatomic, assign) UITableViewCellStyle style;

@end

//

@implementation CKStandardCellController

@synthesize style = _style;
@synthesize text = _text;
@synthesize detailedText = _detailedText;
@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize detailedTextColor = _detailedTextColor;

- (id)initWithStyle:(UITableViewCellStyle)style {
	if (self = [super init]) {
		self.style = style;
	}
	return self;
}

- (id)initWithText:(NSString *)text {
	if ([self initWithStyle:UITableViewCellStyleDefault]) {
		self.text = text;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return self;
}

- (void)dealloc {
	self.text = nil;
	self.detailedText = nil;
	self.backgroundColor = nil;
	self.textColor = nil;
	self.detailedTextColor = nil;
	[super dealloc];
}

//

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:self.style];
	if (self.selectable == NO) cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	if (self.backgroundColor) cell.backgroundColor = self.backgroundColor;
	if (self.textColor) cell.textLabel.textColor = self.textColor;
	if (self.detailedTextColor) cell.detailTextLabel.textColor = self.detailedTextColor;
	
	cell.textLabel.text = self.text;
	cell.detailTextLabel.text = self.detailedText;
}


@end
