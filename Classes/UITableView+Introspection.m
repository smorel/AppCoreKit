//
//  UITableView+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UITableView+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKObject.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


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