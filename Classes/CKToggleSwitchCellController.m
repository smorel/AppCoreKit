//
//  CKToggleSwitchCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKToggleSwitchCellController.h"


@implementation CKToggleSwitchCellController

- (id)initWithTitle:(NSString *)title value:(BOOL)value {
	if (self = [super initWithText:title]) {
		self.value = [NSNumber numberWithBool:value];
		self.selectable = NO;
	}
	return self;
}

//

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [super loadCell];
	
	UISwitch *toggleSwitch = [[[UISwitch alloc] init] autorelease];
	cell.accessoryView = toggleSwitch;
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	UISwitch *toggleSwitch = (UISwitch *)cell.accessoryView;
	toggleSwitch.on = [self.value boolValue];
	[toggleSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

//

- (void)valueChanged:(id)sender {
	self.value = [NSNumber numberWithBool:((UISwitch *)sender).on];
}


@end
