//
//  CKImageCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-01-08.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKImageCellController.h"
#import "IFControlTableViewCell.h"


@implementation CKImageCellController

@synthesize image = _image;
@synthesize highlightedImage = _highlightedImage;
@synthesize accessoryType = _accessoryType;

- (id)initWithImage:(UIImage *)image title:(NSString *)title {
	if (self = [super init]) {
		self.image = image;
		_label = [title retain];
	}
	return self;
	
}

- (id)initWithImage:(UIImage *)image withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model {
	self = [super init];
	if (self != nil) {
		self.image = image;
		_label = [[model objectForKey:key] retain];
	}
	return self;
}

- (id)initWithImage:(UIImage *)image highlight:(UIImage *)highlightedImage withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model {
	self = [super init];
	if (self != nil) {
		self.image = image;
		self.highlightedImage = highlightedImage;
		_label = [[model objectForKey:key] retain];
	}
	return self;
}


- (void)dealloc {
	[_label release];
	[_image release];
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [self tableView:tableView cellWithStyle:UITableViewCellStyleDefault];
	
	if (_image) {
		cell.imageView.image = _image;
		cell.imageView.frame = CGRectOffset(cell.imageView.frame, 20, 10);
		cell.imageView.highlightedImage = _highlightedImage;
	}

	cell.textLabel.text = _label;
	cell.textLabel.numberOfLines = 0;
	cell.accessoryType = _accessoryType;
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Retrieve the cell
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	
	// Calculate the heights
	// FIXME: Calculate labels width dynamically ! ONLY WORKS IN PORTRAIT !
	CGFloat imageWidth = 0;
	if (_image) imageWidth = _image.size.width;
	CGFloat labelHeight = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(260-imageWidth, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
	
	CGFloat imageHeight = _image.size.height;
	return MAX(labelHeight, imageHeight)+20;
}

- (void)setImage:(UIImage *)image {
	[_image release]; _image = [image retain];
}

@end
