//
//  CKUITableViewCell+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableViewCell+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKModelObject.h"


@implementation UITableViewCell (CKIntrospectionAdditions)

- (void)accessoryTypeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITableViewCellAccessoryType",
                                                   UITableViewCellAccessoryNone, 
											   UITableViewCellAccessoryDisclosureIndicator, 
											   UITableViewCellAccessoryDetailDisclosureButton,
											   UITableViewCellAccessoryCheckmark);
}

- (void)editingAccessoryTypeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITableViewCellAccessoryType",
                                                   UITableViewCellAccessoryNone, 
											   UITableViewCellAccessoryDisclosureIndicator, 
											   UITableViewCellAccessoryDetailDisclosureButton,
											   UITableViewCellAccessoryCheckmark);
}

- (void)selectionStyleMetaData :(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITableViewCellSelectionStyle",
                                                   UITableViewCellSelectionStyleNone,
											   UITableViewCellSelectionStyleBlue,
											   UITableViewCellSelectionStyleGray);
}

- (void)editingStyleMetaData :(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITableViewCellEditingStyle",
                                                   UITableViewCellEditingStyleNone,
											   UITableViewCellEditingStyleDelete,
											   UITableViewCellEditingStyleInsert);
}

@end