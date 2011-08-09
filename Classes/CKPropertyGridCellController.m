//
//  CKPropertyGridCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-08.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"


@implementation CKPropertyGridCellController
@synthesize readOnly = _readOnly;

- (id)init{
	[super init];
	self.cellStyle = CKTableViewCellStylePropertyGrid;
	return self;
}

- (CKObjectProperty*)objectProperty{
    NSAssert(self.value == nil || [self.value isKindOfClass:[CKObjectProperty class]],@"Invalid value type");
    return (CKObjectProperty*)self.value;
}

- (void)setValue:(id)value{
    NSAssert(value == nil || [value isKindOfClass:[CKObjectProperty class]],@"Invalid value type");
    [super setValue:value];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
    if(self.readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

@end
