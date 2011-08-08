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
@property (nonatomic, retain, readwrite) NSMutableArray* selectedIndexes;

- (void)setup;

@end


@implementation CKOptionTableViewController

@synthesize optionTableDelegate = _optionTableDelegate;
@synthesize values = _values;
@synthesize labels = _labels;
@synthesize selectedIndexes = _selectedIndexes;
@synthesize multiSelectionEnabled = _multiSelectionEnabled;


- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index {
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelection = YES;
		self.multiSelectionEnabled = NO;
		self.selectedIndexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:index]];
		[self setup];
	}
	return self;	
}

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSArray*)selected multiSelectionEnabled:(BOOL)multiSelect{
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelection = !multiSelect;
		self.multiSelectionEnabled = multiSelect;
		self.selectedIndexes = [NSMutableArray arrayWithArray:selected];
		[self setup];
	}
	return self;	
}

- (void)dealloc {
	[self.values release];
	[self.labels release];
	[self.selectedIndexes release];
    [super dealloc];
}

//

- (void)setup {
	NSMutableArray *cells = [NSMutableArray arrayWithCapacity:self.values.count];
	for (int i=0 ; i< self.values.count ; i++) {
		NSNumber* index = [NSNumber numberWithInt:i];
		
		CKFormCellDescriptor* descriptor = [CKFormCellDescriptor cellDescriptorWithValue:([self.selectedIndexes containsObject:index]) ? [NSNumber numberWithInt:1] :[NSNumber numberWithInt:0]  controllerClass:[CKTableViewCellController class]];
        [descriptor setCreateTarget:self action:@selector(createCell:)];
		[descriptor setSetupTarget:self action:@selector(setupCell:)];
		[descriptor setSelectionTarget:self action:@selector(selectCell:)];
		[cells addObject:descriptor];
	}
	[self addSectionWithCellDescriptors:cells];
}

- (id)createCell:(id)controller{
	CKTableViewCellController* standardController = (CKTableViewCellController*)controller;
    standardController.cellStyle = CKTableViewCellStylePropertyGrid;
    standardController.componentsRatio = 0;
    return nil;
}

- (id)setupCell:(id)controller{
	CKTableViewCellController* standardController = (CKTableViewCellController*)controller;
	NSNumber* index = [NSNumber numberWithInt:standardController.indexPath.row];
	if([self.selectedIndexes containsObject:index]){
		standardController.tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else{
		standardController.tableViewCell.accessoryType = UITableViewCellAccessoryNone;
	}
    NSString* text = self.labels ? [self.labels objectAtIndex:standardController.indexPath.row] : [NSString stringWithFormat:@"%@", [self.values objectAtIndex:standardController.indexPath.row]];
	standardController.tableViewCell.textLabel.text = text;
	return nil;
}


- (id)selectCell:(id)controller{
	CKTableViewCellController* standardController = (CKTableViewCellController*)controller;
	int i = standardController.indexPath.row;
	if(self.multiSelectionEnabled){
		if([standardController.value intValue] == 1){
			standardController.value = [NSNumber numberWithInt:0];
			standardController.tableViewCell.accessoryType = UITableViewCellAccessoryNone;
			[self.selectedIndexes removeObject:[NSNumber numberWithInt:i]];
		}
		else{
			standardController.value = [NSNumber numberWithInt:1];
			standardController.tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
			[self.selectedIndexes addObject:[NSNumber numberWithInt:i]];
		}
	}
	else{
		self.selectedIndexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:i]];
	}
	if (self.optionTableDelegate && [self.optionTableDelegate respondsToSelector:@selector(optionTableViewController:didSelectValueAtIndex:)]){
		[self.optionTableDelegate optionTableViewController:self didSelectValueAtIndex:i];
	}
	return nil;
}

- (NSInteger)selectedIndex{
	NSAssert([self.selectedIndexes count] == 1,@"multiselection => multiple indexes");
	return [[self.selectedIndexes lastObject]intValue];
}


@end
