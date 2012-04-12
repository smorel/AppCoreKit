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

- (void)separatorStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellSeparatorStyle",
                                               UITableViewCellSeparatorStyleNone,
											   UITableViewCellSeparatorStyleSingleLine,
											   UITableViewCellSeparatorStyleSingleLineEtched);
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewStyle",
                                               UITableViewStylePlain,
											   UITableViewStyleGrouped);
}

@end