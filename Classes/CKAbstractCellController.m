//
//  CKBasicCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKAbstractCellController.h"


@implementation CKAbstractCellController

@synthesize target = _target;
@synthesize action = _action;
@synthesize selectable = _selectable;
@synthesize accessoryType = _accessoryType;


- (id)init {
	self = [super init];
	if (self != nil) {
		_selectable = YES;
	}
	return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellWithStyle:(UITableViewStyle)style {
	NSString *cellIdentifier = [NSString stringWithFormat:@"%@-%d", [[self class] description], style];
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier] autorelease];
	}
	
	// Set the selection style
	if (_selectable == YES) cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	else cell.selectionStyle = UITableViewCellSelectionStyleNone;

	cell.accessoryType = _accessoryType;

	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSAssert(@"This method should be implemented in each subclass.", @"");
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_selectable == YES) return indexPath;
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:_selectable];
	if (_selectable == YES && _target && [_target respondsToSelector:_action]) {
		[_target performSelector:_action withObject:self];
	}
}

@end
