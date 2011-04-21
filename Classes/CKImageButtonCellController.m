//
//  CKImageButtonCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-29.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageButtonCellController.h"
#import "CKConstants.h"


@interface CKImageButtonCellController ()

@property (nonatomic, retain) UIImage *highlightedImage;

@end


@implementation CKImageButtonCellController

@synthesize highlightedImage = _highlightedImage;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image hightlightedImage:(UIImage *)hightlightedImage {
	if (self = [super initWithText:title]) {
		self.image = image;
		self.highlightedImage = hightlightedImage;
		self.selectable = NO;
		self.accessoryType = UITableViewCellAccessoryNone;
	}
	return self;
}

- (void)dealloc {
	self.image = nil;
	self.highlightedImage = nil;
	[super dealloc];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = 1000;
	button.frame = cell.contentView.frame;
	button.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
	button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[cell.contentView addSubview:button];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	cell.textLabel.text = nil;
	cell.imageView.image = nil;

	UIButton *button = (UIButton *)[cell.contentView viewWithTag:1000];
	[button setTitle:self.text forState:UIControlStateNormal];
	if (self.image) [button setBackgroundImage:self.image forState:UIControlStateNormal];
	if (self.highlightedImage) [button setBackgroundImage:self.highlightedImage forState:UIControlStateHighlighted];
	[button addTarget:self.target action:self.action forControlEvents:UIControlEventTouchUpInside];
}

@end
