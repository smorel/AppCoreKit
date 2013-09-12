    //
//  CKOptionTableViewController.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOptionTableViewController.h"
#import "CKTableViewCellController+DynamicLayout.h"
#import "CKTableViewCellController+BlockBasedInterface.h"
#import "CKLocalization.h"
#import "CKDebug.h"


@interface CKOptionTableViewController ()

@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain, readwrite) NSMutableArray* selectedIndexes;

- (void)setup;

@end


@implementation CKOptionTableViewController{
	id _optionTableDelegate;
	NSArray *_values;
	NSArray *_labels;
	NSMutableArray* _selectedIndexes;
	BOOL _multiSelectionEnabled;
}

@synthesize optionTableDelegate = _optionTableDelegate;
@synthesize values = _values;
@synthesize labels = _labels;
@synthesize selectedIndexes = _selectedIndexes;
@synthesize multiSelectionEnabled = _multiSelectionEnabled;
@synthesize optionCellStyle;
@synthesize selectionBlock = _selectionBlock;
@synthesize optionCellControllerCreationBlock = _optionCellControllerCreationBlock;



- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index {
	if (labels) {CKAssert(labels.count == values.count, @"labels.count != values.count");}
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelectionEnabled = YES;
		self.multiSelectionEnabled = NO;
		self.selectedIndexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:index]];
        self.optionCellStyle = CKTableViewCellStyleValue1;
	}
	return self;	
}

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSArray*)selected multiSelectionEnabled:(BOOL)multiSelect{
	if (labels) {CKAssert(labels.count == values.count, @"labels.count != values.count");}
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelectionEnabled = !multiSelect;
		self.multiSelectionEnabled = multiSelect;
		self.selectedIndexes = [NSMutableArray arrayWithArray:selected];
        self.optionCellStyle = CKTableViewCellStyleValue1;
	}
	return self;	
}

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSInteger)index style:(UITableViewStyle)thestyle{
	if (labels) {CKAssert(labels.count == values.count, @"labels.count != values.count");}
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelectionEnabled = YES;
		self.multiSelectionEnabled = NO;
		self.selectedIndexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:index]];
        self.optionCellStyle = CKTableViewCellStyleValue1;
        self.style = thestyle;
	}
	return self;	
}

- (id)initWithValues:(NSArray *)values labels:(NSArray *)labels selected:(NSArray*)selected multiSelectionEnabled:(BOOL)multiSelect style:(UITableViewStyle)thestyle{
	if (labels) {CKAssert(labels.count == values.count, @"labels.count != values.count");}
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.values = values;
		self.labels = labels;
		self.stickySelectionEnabled = !multiSelect;
		self.multiSelectionEnabled = multiSelect;
		self.selectedIndexes = [NSMutableArray arrayWithArray:selected];
        self.optionCellStyle = CKTableViewCellStyleValue1;
        self.style = thestyle;
	}
	return self;	
}


- (void)dealloc {
	[_values release];
	[_labels release];
	[_selectedIndexes release];
    [_selectionBlock release];
    [_optionCellControllerCreationBlock release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setup];
}

//


- (id)selectCell:(id)controller{
	CKTableViewCellController* standardController = (CKTableViewCellController*)controller;
	NSInteger i = standardController.indexPath.row;
	if(self.multiSelectionEnabled){
		if([standardController.value intValue] == 1){
			standardController.value = [NSNumber numberWithInt:0];
			standardController.accessoryType = UITableViewCellAccessoryNone;
			[self.selectedIndexes removeObject:[NSNumber numberWithInteger:i]];
		}
		else{
			standardController.value = [NSNumber numberWithInt:1];
			standardController.accessoryType = UITableViewCellAccessoryCheckmark;
			[self.selectedIndexes addObject:[NSNumber numberWithInteger:i]];
		}
	}
	else{
		self.selectedIndexes = [NSMutableArray arrayWithObject:[NSNumber numberWithInteger:i]];
	}
    
    
    if(_selectionBlock){
        _selectionBlock(self,i);
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
        
        CKTableViewCellController* cellController = nil;
        if(self.optionCellControllerCreationBlock){
            cellController = self.optionCellControllerCreationBlock(text,[self.values objectAtIndex:i]);
            cellController.flags |= CKTableViewCellFlagSelectable;
            if(cellController.selectionStyle == UITableViewCellSelectionStyleNone){
                cellController.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
        }else{
            cellController = [CKTableViewCellController cellController];
            cellController.cellStyle = self.optionCellStyle;
            cellController.componentsRatio = 0;
            cellController.text = _(text);
        }
        
        if(cellController.name == nil){
            cellController.name = @"OptionCell";
        }
        
        cellController.value = ([self.selectedIndexes containsObject:index]) ? [NSNumber numberWithInt:1] :[NSNumber numberWithInt:0];
        
        if([self.selectedIndexes containsObject:index]){
            cellController.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cellController.accessoryType = UITableViewCellAccessoryNone;
        }

        [cellController setSelectionBlock:^(CKTableViewCellController *controller) {
            [bself selectCell:controller];
        }];
        
		[cellControllers addObject:cellController];
	}
    
    
    CKFormSection* section = [CKFormSection sectionWithCellControllers:cellControllers];
	[self addSections:[NSArray arrayWithObject:section]];
}

- (NSInteger)selectedIndex{
	//CKAssert([self.selectedIndexes count] == 1,@"multiselection => multiple indexes");
	return [[self.selectedIndexes lastObject]intValue];
}


@end
