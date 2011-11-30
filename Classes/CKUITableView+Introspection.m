//
//  CKUITableView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableView+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObject.h"


@implementation UITableView (CKIntrospectionAdditions)

- (void)separatorStyleMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITableViewCellSeparatorStyle",
                                               UITableViewCellSeparatorStyleNone,
											   UITableViewCellSeparatorStyleSingleLine,
											   UITableViewCellSeparatorStyleSingleLineEtched);
}

- (void)styleMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITableViewStyle",
                                               UITableViewStylePlain,
											   UITableViewStyleGrouped);
}

@end