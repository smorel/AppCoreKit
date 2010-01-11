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

- (id)initWithImage:(UIImage *)newImage withLabel:(NSString *)newLabel atKey:(NSString *)newKey inModel:(id<IFCellModel>)newModel {
	self = [super init];
	if (self != nil) {
		image = [newImage retain];
		imageView = nil;
		label = [newLabel retain];
		key = [newKey retain];
		model = [newModel retain];
	}
	return self;
}


- (void)dealloc {
	[label release];
	[key release];
	[model release];
	
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [self tableView:tableView cellWithStyle:UITableViewCellStyleDefault];
	
	if (image) {
		cell.imageView.image = image;
		cell.imageView.frame = CGRectOffset(cell.imageView.frame, 20, 10);
	}
	if (label) cell.textLabel.text = [model objectForKey:key];
	cell.textLabel.numberOfLines = 0;
	imageView = [cell.imageView retain];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Retrieve the cell
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	
	// Calculate the heights
	// FIXME: Calculate labels width dynamically ! ONLY WORKS IN PORTRAIT !
	CGFloat labelHeight = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(70, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
	
	CGFloat imageHeight = image.size.height;
	return MAX(labelHeight, imageHeight)+20;
}

- (void)setNewImage:(UIImage *)newImage {
	image = [newImage retain];
	imageView.image = image;
}


@end
