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

- (void)accessoryTypeMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UITableViewCellAccessoryNone, 
											   UITableViewCellAccessoryDisclosureIndicator, 
											   UITableViewCellAccessoryDetailDisclosureButton,
											   UITableViewCellAccessoryCheckmark);
}

- (void)editingAccessoryTypeMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UITableViewCellAccessoryNone, 
											   UITableViewCellAccessoryDisclosureIndicator, 
											   UITableViewCellAccessoryDetailDisclosureButton,
											   UITableViewCellAccessoryCheckmark);
}

- (void)selectionStyleMetaData :(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UITableViewCellSelectionStyleNone,
											   UITableViewCellSelectionStyleBlue,
											   UITableViewCellSelectionStyleGray);
}

- (void)editingStyleMetaData :(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UITableViewCellEditingStyleNone,
											   UITableViewCellEditingStyleDelete,
											   UITableViewCellEditingStyleInsert);
}

@end