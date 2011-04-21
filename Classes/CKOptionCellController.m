//
//  CKOptionCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOptionCellController.h"


@interface CKOptionCellController ()

@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSArray *labels;

@end



@implementation CKOptionCellController

@synthesize values = _values;
@synthesize labels = _labels;


- (id)initWithTitle:(NSString *)title values:(NSArray *)values labels:(NSArray *)labels {
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");

	if (self = [super initWithText:title]) {
		self.values = values;
		self.labels = labels;
		self.style = UITableViewCellStyleValue1;
	}
	return self;
}

- (void)dealloc {
	self.values = nil;
	self.labels = nil;
	[super dealloc];
}

- (NSString *)labelForValue:(id)value {
	if (value == nil) return nil;
	return self.labels ? [self.labels objectAtIndex:[self.values indexOfObject:value]] : [NSString stringWithFormat:@"%@", value];
}

//

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	cell.textLabel.text = self.text;
	cell.detailTextLabel.text = [self labelForValue:self.value];
}

- (void)didSelectRow {
	[super didSelectRow];
	CKOptionTableViewController *optionTableController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self.values indexOfObject:self.value]] autorelease];
	optionTableController.title = self.text;
	optionTableController.optionTableDelegate = self;
	[self.parentController.navigationController pushViewController:optionTableController animated:YES];
}

//

- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index {
	self.value = [self.values objectAtIndex:index];
	[self.parentController.navigationController popViewControllerAnimated:YES];
}

@end
