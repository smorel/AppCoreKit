    //
//  CKOptionTableViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOptionTableViewController.h"
#import "CKStandardCellController.h"


@interface CKOptionTableViewController ()

@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, readwrite) NSInteger selectedIndex;

@end


@implementation CKOptionTableViewController

@synthesize optionTableDelegate = _optionTableDelegate;
@synthesize values = _values;
@synthesize labels = _labels;
@synthesize selectedIndex = _selectedIndex;


- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index {
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.selectedIndex = index;
	}
	return self;	
}

- (void)dealloc {
	[self.values release];
	[self.labels release];
    [super dealloc];
}

//

- (void)setup {
	NSMutableArray *cells = [NSMutableArray arrayWithCapacity:self.values.count];
	for (int i=0 ; i<self.values.count ; i++) {
		NSString *text = self.labels ? [self.labels objectAtIndex:i] : [NSString stringWithFormat:@"%@", [self.values objectAtIndex:i]];
		CKStandardCellController *cell = [[[CKStandardCellController alloc] initWithText:text] autorelease];
		cell.accessoryType = (i == self.selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		cell.value = (i == self.selectedIndex) ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0];
		[cells addObject:cell];
	}
	[self addSectionWithCellControllers:cells];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	self.selectedIndex = indexPath.row;
	if (self.optionTableDelegate && [self.optionTableDelegate respondsToSelector:@selector(optionTableViewController:didSelectValueAtIndex:)])
		[self.optionTableDelegate optionTableViewController:self didSelectValueAtIndex:self.selectedIndex];
}



@end
