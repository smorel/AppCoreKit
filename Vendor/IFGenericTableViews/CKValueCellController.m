//
//  CKValueCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKValueCellController.h"
#import "IFControlTableViewCell.h"


@implementation CKValueCellController

- (id)initWithStyle:(UITableViewCellStyle)newStyle withLabel:(NSString *)newLabel atKey:(NSString *)newKey inModel:(id<IFCellModel>)newModel {
	self = [super init];
	if (self != nil) {
		style = newStyle;
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
	
    UITableViewCell *cell = [self tableView:tableView cellWithStyle:style];

	cell.textLabel.text = label;
	cell.textLabel.numberOfLines = 0;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [model objectForKey:key]];
	cell.detailTextLabel.numberOfLines = 0;
	cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Retrieve the cell
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	
	// Calculate the heights
	// FIXME: Calculate labels width dynamically ! ONLY WORKS IN PORTRAIT !
	CGFloat labelHeight = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(70, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
	CGFloat detailedLabelHeight = [cell.detailTextLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
	
	return MAX(labelHeight, detailedLabelHeight)+20;
}

@end
