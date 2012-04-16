//
//  CKOptionCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOptionCellController.h"


@interface CKOptionCellController ()
@property (nonatomic, retain, readwrite) id currentValue;
@end

@implementation CKOptionCellController

@synthesize values = _values;
@synthesize labels = _labels;
@synthesize multiSelectionEnabled = _multiSelectionEnabled;
@synthesize currentValue = _currentValue;
@synthesize readOnly = _readOnly;
@synthesize optionCellStyle;
@synthesize title = _title;

- (id)initWithTitle:(NSString *)thetitle values:(NSArray *)thevalues labels:(NSArray *)thelabels {
	if (thelabels) NSAssert(thelabels.count == thevalues.count, @"labels.count != values.count");

	self = [super init];
    self.title = thetitle;
    self.values = thevalues;
    self.labels = thelabels;
    self.cellStyle = CKTableViewCellStyleValue1;
    self.optionCellStyle = CKTableViewCellStyleValue1;
	
	return self;
}

- (id)initWithTitle:(NSString *)title values:(NSArray *)values labels:(NSArray *)labels multiSelectionEnabled:(BOOL)multiSelectionEnabled{
	self = [self initWithTitle:title values:values labels:labels];
	self.multiSelectionEnabled = multiSelectionEnabled;
    if(multiSelectionEnabled){
        for(id v in values){
            NSAssert([v isKindOfClass:[NSNumber class]],@"multiSelectionEnabled can only get used with integer values !!!");
        }
    }
	return self;
}

- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

- (void)dealloc {
	self.values = nil;
	self.labels = nil;
    self.title = nil;
	[_currentValue release];
    _currentValue = nil;
	[super dealloc];
}

- (NSString *)labelForValue:(id)value {
	if (value == nil) return nil;
	if(self.multiSelectionEnabled){
		NSMutableString* str = [NSMutableString string];
		NSInteger intValue = [value intValue];
		for(int i= 0;i < [self.values count]; ++i){
			NSNumber* v = [self.values objectAtIndex:i];
			NSString* l = [self.labels objectAtIndex:i];
			if(intValue & [v intValue]){
				if([str length] > 0){
					[str appendFormat:@" | %@",l];
				}
				else{
					[str appendString:l];
				}
			}
		}
	}
	else{
		NSInteger index = [value intValue];
		return (self.labels && index != NSNotFound) ? [self.labels objectAtIndex:index] : [NSString stringWithFormat:@"%@", value];
	}
	return nil;
}

- (NSArray*)indexesForValue:(NSInteger) value{
	NSMutableArray* indexes = [NSMutableArray array];
	NSInteger intValue = value;
	for(int i= 0;i < [self.values count]; ++i){
		NSNumber* v = [self.values objectAtIndex:i];
		if(intValue & [v intValue]){
			[indexes addObject:[NSNumber numberWithInt:i]];
		}
	}
	return indexes;
}

//

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	cell.textLabel.text = self.title;
	cell.detailTextLabel.text = [self labelForValue:self.value];
    
    if(self.readOnly){
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
	//cell.textLabel.backgroundColor = [UIColor clearColor];
    //cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    //cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    //cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
    
    if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        }  
        else{
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        }
    }  

    if(self.readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setReadOnly:(BOOL)bo{
    _readOnly = bo;
    
    if(bo){
        self.flags = CKItemViewFlagNone;
        return;
    }
    self.flags = CKItemViewFlagSelectable;
}

- (void)didSelectRow {
	[super didSelectRow];
    CKTableViewController* tableController = (CKTableViewController*)[self containerController];
	CKOptionTableViewController *optionTableController = nil;
	if(self.multiSelectionEnabled){
		optionTableController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self indexesForValue:[self.value intValue]] multiSelectionEnabled:YES style:[tableController style]] autorelease];
	}
	else{
		optionTableController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self.value intValue] style:[tableController style]] autorelease];
	}
    optionTableController.optionCellStyle = self.optionCellStyle;
	optionTableController.title = self.title;
	optionTableController.optionTableDelegate = self;
	[self.containerController.navigationController pushViewController:optionTableController animated:YES];
}

//

- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index {
	if(self.multiSelectionEnabled){
		NSArray* indexes = tableViewController.selectedIndexes;
		NSInteger v = 0;
		for(NSNumber* index in indexes){
			v |= [[self.values objectAtIndex:[index intValue]]intValue];
		}
		self.value = [NSNumber numberWithInt:v];
        self.currentValue = [NSNumber numberWithInt:v];
	}
	else{
		self.value = [NSNumber numberWithInt:tableViewController.selectedIndex];
        self.currentValue = [self.values objectAtIndex:tableViewController.selectedIndex];
	}
	
	if(self.tableViewCell){
        CKTableViewController* tableViewController = [self parentTableViewController];
		self.tableViewCell.detailTextLabel.text = [self labelForValue:self.value];
        
        [tableViewController onBeginUpdates];
        [tableViewController onEndUpdates];
	}
	
	if(!self.multiSelectionEnabled){
		[self.containerController.navigationController popViewControllerAnimated:YES];
	}
}

@end
