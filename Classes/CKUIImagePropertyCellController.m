//
//  CKUIImagePropertyCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIImagePropertyCellController.h"


@implementation CKUIImagePropertyCellController

- (id)init{
    self = [super init];
    self.cellStyle = UITableViewCellStyleSubtitle;
    return self;
}

- (void)setupCell:(UITableViewCell *)cell{
    [super setupCell:cell];
    CKObjectProperty* property = self.value;
    UIImage* image = [property value];
    cell.imageView.image = image;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
    return CKItemViewFlagNone;
}

@end
