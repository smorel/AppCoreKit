//
//  UITableViewCell+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UITableViewCell+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKObject.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


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