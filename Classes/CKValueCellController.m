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

- (id)initWithStyle:(UITableViewCellStyle)style text:(NSString *)text value:(id)value {
	if (self = [super init]) {
		_style = style;
		_text = [text retain];
		_value = [value retain];
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model {
	if (self = [super init]) {
		_style = style;
		_text = [label retain];
		_value = [[model objectForKey:key] retain];
	}
	return self;
}

- (void)dealloc {
	[_text release];
	[_value release];
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = [self tableView:tableView cellWithStyle:_style];

	cell.textLabel.text = _text;
	cell.textLabel.numberOfLines = 0;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _value];
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