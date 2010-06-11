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

//

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:self.style];
	if (self.selectable == NO) cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	cell.textLabel.text = self.text;
	cell.detailTextLabel.text = self.detailedText;
}


@end
