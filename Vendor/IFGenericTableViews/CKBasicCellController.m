//
//  CKBasicCellController.m
//  CloudKit
//
//  Created by Oli Kenobi on 09-12-15.
//  Copyright 2009 Kenobi Studios. All rights reserved.
//

#import "CKBasicCellController.h"


@implementation CKBasicCellController

@synthesize isSelectable;


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:isSelectable];
	if (_target && [_target respondsToSelector:_action]) {
		[_target performSelector:_action];
	}
}


- (void)setAction:(SEL)action onTarget:(id)target {
	_target = target;
	_action = action;
	isSelectable = YES;
}

@end
