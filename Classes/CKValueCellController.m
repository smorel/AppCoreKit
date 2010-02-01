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

- (id)initWithStyle:(UITableViewCellStyle)style withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model {
	self = [super init];
	if (self != nil) {
		_style = style;
		_label = [label retain];
		_key = [key retain];
		_model = [model retain];
	}
	return self;
}

- (void)dealloc {
	[_label release];
	[_key release];
	[_model release];
	
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = [self tableView:tableView cellWithStyle:_style];

	cell.textLabel.text = _label;
	cell.textLabel.numberOfLines = 0;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [_model objectForKey:_key]];
	cell.detailTextLabel.numberOfLines = 0;
	cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (_style == UITableViewCellStyleValue2) {
		// Retrieve the cell
		UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
		
		// Calculate the heights
		// FIXME: Calculate labels width dynamically ! ONLY WORKS IN PORTRAIT !
		CGFloat labelHeight = [cell.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(70, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
		CGFloat detailedLabelHeight = [cell.detailTextLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
		
		return MAX(labelHeight, detailedLabelHeight)+20;		
	}
	return 44.0f;
}

@end
