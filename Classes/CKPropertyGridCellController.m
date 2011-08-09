//
//  CKPropertyGridCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-08.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKNSObject+Bindings.h"


@implementation CKPropertyGridCellController
@synthesize readOnly = _readOnly;

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
    _oldBackgroundColor = nil;
	return self;
}

- (CKObjectProperty*)objectProperty{
    NSAssert(self.value == nil || [self.value isKindOfClass:[CKObjectProperty class]],@"Invalid value type");
    return (CKObjectProperty*)self.value;
}

- (void)setValue:(id)value{
    if(![_value isEqual:value]){
        NSAssert(value == nil || [value isKindOfClass:[CKObjectProperty class]],@"Invalid value type");
        [super setValue:value];
    
        BOOL validity = [self isValidValue:[value value]];
        [self changeUIToReflectValidity:validity];
    }
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
    if(self.readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}


- (void)setupCell:(UITableViewCell*)cell{
    [super setupCell:cell];
    
    [self beginBindingsContextByKeepingPreviousBindings];
    [cell bind:@"backgroundColor" withBlock:^(id value) {
        BOOL validity = [self isValidValue:[[self objectProperty] value]];
        [self changeUIToReflectValidity:validity];
    }];
    [self endBindingsContext];
    
    //set default color
    if(cell.backgroundColor == nil){
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL)isValidValue:(id)value{
    CKObjectProperty* property = [self objectProperty];
    CKModelObjectPropertyMetaData* metaData = [property metaData];
    if(metaData.validationPredicate){
        return [metaData.validationPredicate evaluateWithObject:value];
    }
    return YES;
}

- (void)setValueInObjectProperty:(id)value{
    BOOL validity = [self isValidValue:value];
    [self changeUIToReflectValidity:validity];
    
    CKObjectProperty* property = [self objectProperty];
    [property setValue:value];
    [[NSNotificationCenter defaultCenter]notifyPropertyChange:property];
}

- (void)changeUIToReflectValidity:(BOOL)validity{
    if(self.view == nil)
        return;
    
    if(!validity && _oldBackgroundColor == nil){
        _oldBackgroundColor = [self.tableViewCell.backgroundColor copy];
        if(_oldBackgroundColor){
            self.tableViewCell.backgroundColor = [UIColor redColor];
        }
    }
    else if(validity && _oldBackgroundColor){
        self.tableViewCell.backgroundColor = _oldBackgroundColor;
        _oldBackgroundColor = nil;
    }
}

@end
