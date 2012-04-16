//
//  CKOptionPropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-15.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKOptionPropertyCellController.h"
#import "CKLocalization.h"
#import "CKNSObject+Bindings.h"

#import "CKUIViewController+Style.h"
#import "CKStyleManager.h"


@interface CKOptionPropertyCellController ()
@property (nonatomic,retain) NSArray* values;
@property (nonatomic,retain) NSArray* labels;
@property (nonatomic,retain) NSString* internalBindingContext;

@property (nonatomic,readonly) BOOL multiSelectionEnabled;
@property (nonatomic,retain,readwrite) CKOptionTableViewController* optionsViewController;
@end

@implementation CKOptionPropertyCellController
@synthesize optionCellStyle;
@synthesize values;
@synthesize labels;
@synthesize multiSelectionEnabled;
@synthesize optionsViewController = _optionsViewController;
@synthesize internalBindingContext = _internalBindingContext;



- (void)postInit{
    [super postInit];
    
    self.cellStyle = CKTableViewCellStylePropertyGrid;
    self.optionCellStyle = CKTableViewCellStylePropertyGrid;
    self.internalBindingContext = [NSString stringWithFormat:@"<%p>_CKOptionPropertyCellController",self];
    self.flags = CKItemViewFlagNone;
}


- (void)dealloc{
    [NSObject removeAllBindingsForContext:self.internalBindingContext];
    self.values = nil;
    self.labels = nil;
    [_optionsViewController release];
    [_internalBindingContext release];
    [super dealloc];
}

- (void)setupLabelsAndValues{
    CKProperty* property = [self objectProperty];
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    NSDictionary* valuesAndLabels = nil;
    if(attributes.valuesAndLabels) valuesAndLabels = attributes.valuesAndLabels;
    else if(attributes.enumDescriptor) valuesAndLabels = attributes.enumDescriptor.valuesAndLabels;

    NSAssert(valuesAndLabels != nil,@"No valuesAndLabels or EnumDefinition declared for property %@",property);
    NSArray* orderedLabels = [[valuesAndLabels allKeys]sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* str1 = _(obj1);
        NSString* str2 = _(obj2);
        return [str1 compare:str2];
    }];
    
    NSMutableArray* orderedValues = [NSMutableArray array];
    for(NSString* label in orderedLabels){
        id value = [valuesAndLabels objectForKey:label];
        [orderedValues addObject:value];
    }
    
    self.labels = orderedLabels;
    self.values = orderedValues;
}

- (BOOL)multiSelectionEnabled{
    CKProperty* property = [self objectProperty];
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    return (attributes.enumDescriptor && attributes.enumDescriptor.isBitMask);
}

- (NSString *)labelForValue:(NSInteger)intValue {
	if (intValue < 0
		|| intValue == NSNotFound) {
		
		CKProperty* property = [self objectProperty];
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		NSString* str = [NSString stringWithFormat:@"%@_PlaceHolder",descriptor.name];
		return _(str);
	}
	
	if(self.multiSelectionEnabled){
		NSMutableString* str = [NSMutableString string];
		for(int i= 0;i < [self.values count]; ++i){
			NSNumber* v = [self.values objectAtIndex:i];
			NSString* l = [self.labels objectAtIndex:i];
			if(intValue & [v intValue]){
				if([str length] > 0){
					[str appendFormat:@"%@%@",_(@"_|_"),_(l)];
				}
				else{
					[str appendString:_(l)];
				}
			}
		}
        return str;
	}
	else{
		NSInteger index = intValue;
        NSString* str = (self.labels && index != NSNotFound) ? [self.labels objectAtIndex:index] : [NSString stringWithFormat:@"%@", intValue];
		return _(str);
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

- (NSInteger)currentValue{
    CKProperty* property = [self objectProperty];
    if(self.multiSelectionEnabled){
        return [[property value]intValue];
    }
    else{
        NSInteger index = [self.values indexOfObject:[property value]];
        return index;
    }
    return -1;
}

//

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
    
    [self setupLabelsAndValues];
    
    if(self.readOnly){
        self.fixedSize = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        self.fixedSize = NO;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CKProperty* property = [self objectProperty];
    
    cell.textLabel.text = _(property.name);
	cell.detailTextLabel.text = [self labelForValue:[self currentValue]];
    if(cell.detailTextLabel.text == nil){
        cell.detailTextLabel.text = @" ";
    }

    [NSObject beginBindingsContext:self.internalBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
    [property.object bind:property.keyPath withBlock:^(id value){
        self.tableViewCell.detailTextLabel.text = [self labelForValue:[self currentValue]];
    }];
    [NSObject endBindingsContext];
}

- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
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
    [super setReadOnly:bo];
    
    if(bo){
        self.flags = CKItemViewFlagNone;
        return;
    }
    self.flags = CKItemViewFlagSelectable;
}

- (void)didSelect {
    CKProperty* property = [self objectProperty];
	
	NSString* propertyNavBarTitle = [NSString stringWithFormat:@"%@_NavBarTitle",property.name];
	NSString* propertyNavBarTitleLocalized = _(propertyNavBarTitle);
	if ([propertyNavBarTitleLocalized isEqualToString:[NSString stringWithFormat:@"%@_NavBarTitle",property.name]]) {
		propertyNavBarTitleLocalized = _(property.name);
	}
    
    CKTableViewController* tableController = (CKTableViewController*)[self containerController];
	if(self.multiSelectionEnabled){
		self.optionsViewController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self indexesForValue:[self currentValue]] multiSelectionEnabled:YES style:[tableController style]] autorelease];
	}
	else{
		self.optionsViewController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self  currentValue] style:[tableController style]] autorelease];
	}
    self.optionsViewController.optionCellStyle = self.optionCellStyle;
	self.optionsViewController.title = propertyNavBarTitleLocalized;
	self.optionsViewController.optionTableDelegate = self;
    
    [super didSelect];//here because we could want to act on optionsViewController in selectionBlock
    
	[self.containerController.navigationController pushViewController:self.optionsViewController animated:YES];
}

//

- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index {
    [NSObject removeAllBindingsForContext:self.internalBindingContext];
    
    if(self.multiSelectionEnabled){
		NSArray* indexes = tableViewController.selectedIndexes;
		NSInteger v = 0;
		for(NSNumber* index in indexes){
			v |= [[self.values objectAtIndex:[index intValue]]intValue];
		}
        
        self.tableViewCell.detailTextLabel.text = [self labelForValue:v];
        [self setValueInObjectProperty:[NSNumber numberWithInt:v]];
    }
	else{
        NSInteger index = tableViewController.selectedIndex;
        self.tableViewCell.detailTextLabel.text = [self labelForValue:index];
        id value = [self.values objectAtIndex:index];
        [self setValueInObjectProperty:value];
	}
    
    //Notify parent controller that this row height could have vhanged
    CKTableViewController* parentTableViewController = [self parentTableViewController];
    [parentTableViewController onBeginUpdates];
    [parentTableViewController onEndUpdates];
	
	if(!self.multiSelectionEnabled){
		[self.containerController.navigationController popViewControllerAnimated:YES];
	}
    
    CKProperty* property = [self objectProperty];
    [NSObject beginBindingsContext:self.internalBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
    [property.object bind:property.keyPath withBlock:^(id value){
        self.tableViewCell.detailTextLabel.text = [self labelForValue:[self currentValue]];
    }];
    [NSObject endBindingsContext];
}

@end
