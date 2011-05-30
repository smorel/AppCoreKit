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

- (void)setup;

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
		self.stickySelection = YES;
		[self setup];
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
	for (int i=0 ; i< self.values.count ; i++) {
		CKFormCellDescriptor* descriptor = [CKFormCellDescriptor cellDescriptorWithValue:(i == self.selectedIndex) ? [NSNumber numberWithInt:1] :[NSNumber numberWithInt:0]  controllerClass:[CKStandardCellController class]];
		[descriptor.params setObject:[CKCallback callbackWithTarget:self action:@selector(initCell:)] forKey:CKObjectViewControllerFactoryItemSetup];
		[descriptor.params setObject:[CKCallback callbackWithTarget:self action:@selector(selectCell:)] forKey:CKObjectViewControllerFactoryItemSelection];
		[cells addObject:descriptor];
	}
	[self addSectionWithCellDescriptors:cells];
}

- (id)initCell:(id)controller{
	CKStandardCellController* standardController = (CKStandardCellController*)controller;
	int i = standardController.indexPath.row;
	if(i == self.selectedIndex){
		standardController.tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else{
		standardController.tableViewCell.accessoryType = UITableViewCellAccessoryNone;
	}
	standardController.text = self.labels ? [self.labels objectAtIndex:i] : [NSString stringWithFormat:@"%@", [self.values objectAtIndex:i]];
	return nil;
}


- (id)selectCell:(id)controller{
	CKStandardCellController* standardController = (CKStandardCellController*)controller;
	int i = standardController.indexPath.row;
	self.selectedIndex = i;
	if (self.optionTableDelegate && [self.optionTableDelegate respondsToSelector:@selector(optionTableViewController:didSelectValueAtIndex:)])
		[self.optionTableDelegate optionTableViewController:self didSelectValueAtIndex:self.selectedIndex];
	return nil;
}


@end
