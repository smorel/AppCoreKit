//
//  CKUITableViewCell+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableViewCell+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObject.h"


@implementation UITableViewCell (CKIntrospectionAdditions)

- (void)accessoryTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellAccessoryType",
                                                   UITableViewCellAccessoryNone, 
											   UITableViewCellAccessoryDisclosureIndicator, 
											   UITableViewCellAccessoryDetailDisclosureButton,
											   UITableViewCellAccessoryCheckmark);
}

- (void)editingAccessoryTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellAccessoryType",
                                                   UITableViewCellAccessoryNone, 
											   UITableViewCellAccessoryDisclosureIndicator, 
											   UITableViewCellAccessoryDetailDisclosureButton,
											   UITableViewCellAccessoryCheckmark);
}

- (void)selectionStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellSelectionStyle",
                                                   UITableViewCellSelectionStyleNone,
											   UITableViewCellSelectionStyleBlue,
											   UITableViewCellSelectionStyleGray);
}

- (void)editingStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellEditingStyle",
                                                   UITableViewCellEditingStyleNone,
											   UITableViewCellEditingStyleDelete,
											   UITableViewCellEditingStyleInsert);
}

@end