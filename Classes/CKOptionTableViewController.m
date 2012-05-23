    //
//  CKOptionTableViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOptionTableViewController.h"
#import "CKTableViewCellController+CKDynamicLayout.h"
#import "CKTableViewCellController+CKBlockBasedInterface.h"
#import "CKLocalization.h"


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
@synthesize optionCellStyle;



- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index {
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelection = YES;
		self.multiSelectionEnabled = NO;
		self.selectedIndexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:index]];
        self.optionCellStyle = CKTableViewCellStyleValue1;
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
        self.optionCellStyle = CKTableViewCellStyleValue1;
	}
	return self;	
}

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index style:(UITableViewStyle)thestyle{
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelection = YES;
		self.multiSelectionEnabled = NO;
		self.selectedIndexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:index]];
        self.optionCellStyle = CKTableViewCellStyleValue1;
        self.style = thestyle;
	}
	return self;	
}

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSArray*)selected multiSelectionEnabled:(BOOL)multiSelect style:(UITableViewStyle)thestyle{
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelection = !multiSelect;
		self.multiSelectionEnabled = multiSelect;
		self.selectedIndexes = [NSMutableArray arrayWithArray:selected];
        self.optionCellStyle = CKTableViewCellStyleValue1;
        self.style = thestyle;
	}
	return self;	
}


- (void)dealloc {
	[self.values release];
	[self.labels release];
	[self.selectedIndexes release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self clear];
    [self setup];
    [super viewWillAppear:animated];
}

//


- (id)selectCell:(id)controller{
	CKTableViewCellController* standardController = (CKTableViewCellController*)controller;
	int i = standardController.indexPath.row;
	if(self.multiSelectionEnabled){
		if([standardController.value intValue] == 1){
			standardController.value = [NSNumber numberWithInt:0];
			standardController.accessoryType = UITableViewCellAccessoryNone;
			[self.selectedIndexes removeObject:[NSNumber numberWithInt:i]];
		}
		else{
			standardController.value = [NSNumber numberWithInt:1];
			standardController.accessoryType = UITableViewCellAccessoryCheckmark;
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


- (void)setup {
	NSMutableArray *cellControllers = [NSMutableArray arrayWithCapacity:self.values.count];
    
	for (int i=0 ; i< self.values.count ; i++) {
		NSNumber* index = [NSNumber numberWithInt:i];
		
        __block CKOptionTableViewController* bself = self;
        
        CKTableViewCellController* cellController = [CKTableViewCellController cellController];
        cellController.value = ([self.selectedIndexes containsObject:index]) ? [NSNumber numberWithInt:1] :[NSNumber numberWithInt:0];
        cellController.cellStyle = self.optionCellStyle;
        
        /*
        if(cellController.cellStyle == CKTableViewCellStyleIPadForm
           || cellController.cellStyle == CKTableViewCellStyleIPhoneForm){
            cellController.textAlignment = UITextAlignmentLeft;
        }
         */
        
        cellController.componentsRatio = 0;
        
        if([self.selectedIndexes containsObject:index]){
            cellController.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cellController.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSString* text = @"UNKNOWN";
        NSUInteger rowIndex = i;
        if(_labels){
            if(rowIndex < [_labels count]){
                text = [_labels objectAtIndex:rowIndex];
            }
        }
        else{
            if(rowIndex < [_values count]){
                text = [_values objectAtIndex:rowIndex];
            }
        }
        
        cellController.text = _(text);

        [cellController setSelectionBlock:^(CKTableViewCellController *controller) {
            [bself selectCell:controller];
        }];
        
		[cellControllers addObject:cellController];
	}
    CKFormSection* section = [CKFormSection sectionWithCellControllers:cellControllers];
	[self addSections:[NSArray arrayWithObject:section]];
}

- (NSInteger)selectedIndex{
	//NSAssert([self.selectedIndexes count] == 1,@"multiselection => multiple indexes");
	return [[self.selectedIndexes lastObject]intValue];
}


@end
