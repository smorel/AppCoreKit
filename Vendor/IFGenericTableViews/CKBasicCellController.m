//
//  CKBasicCellController.m
//  CloudKit
//
//  Created by Oli Kenobi on 09-12-15.
//  Copyright 2009 Kenobi Studios. All rights reserved.
//

#import "CKBasicCellController.h"


@implementation CKBasicCellController

@synthesize target = _target;
@synthesize action = _action;
@synthesize selectable = _selectable;


- (id)init {
	self = [super init];
	if (self != nil) {
		_selectable = YES;
	}
	return self;
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
		[_target performSelector:_action];
	}
}


@end
