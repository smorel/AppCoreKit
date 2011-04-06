//
//  CKToggleSwitchCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKToggleSwitchCellController.h"

@interface CKToggleSwitchCellController ()

@property (nonatomic, assign) CKToggleSwitchCellStyle switchCellStyle;

- (void)toggleCheckmark;

@end

//

@implementation CKToggleSwitchCellController

@synthesize switchCellStyle = _switchCellStyle;
@synthesize enabled = _enabled;

- (id)initWithTitle:(NSString *)title value:(BOOL)value style:(CKToggleSwitchCellStyle)style {
	if (self = [super initWithText:title]) {
		self.value = [NSNumber numberWithBool:value];
		self.switchCellStyle = style;
		self.selectable = (self.switchCellStyle == CKToggleSwitchCellStyleCheckmark);
		self.enabled = YES;
	}
	return self;
}

- (id)initWithTitle:(NSString *)title value:(BOOL)value {
	return [self initWithTitle:title value:value style:CKToggleSwitchCellStyleSwitch];
}

//

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [super loadCell];

	if (self.switchCellStyle == CKToggleSwitchCellStyleSwitch) {
		UISwitch *toggleSwitch = [[[UISwitch alloc] init] autorelease];
		cell.accessoryView = toggleSwitch;
	}
	if (self.switchCellStyle == CKToggleSwitchCellStyleCheckmark) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];

	if (self.switchCellStyle == CKToggleSwitchCellStyleCheckmark) {
		cell.accessoryType = [self.value boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	else {
		UISwitch *toggleSwitch = (UISwitch *)cell.accessoryView;
		toggleSwitch.on = [self.value boolValue];
		toggleSwitch.enabled = self.enabled;
		
		// FIXME: Remove old target for reuse
		[toggleSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];		
	}
}

// UISwitch specific

- (void)switchValueChanged:(id)sender {
	self.value = [NSNumber numberWithBool:((UISwitch *)sender).on];
}

// Checkmark specific

- (void)didSelectRow {
	if (self.switchCellStyle == CKToggleSwitchCellStyleCheckmark) {
		[self toggleCheckmark];
		return;
	}
	[super didSelectRow];
}

- (void)toggleCheckmark {
	self.tableViewCell.accessoryType = [self.value boolValue] ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
	self.value = [NSNumber numberWithBool:(![self.value boolValue])];
}

@end
