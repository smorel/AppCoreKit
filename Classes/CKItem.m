//
//  CKItem.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKItem.h"
#import "CKAttribute.h"

#import "CKDictionaryFromAttributesTransformer.h"

@implementation CKItem

@dynamic name;
@dynamic createdAt;
@dynamic domain;
@dynamic attributes;

@end

@implementation CKItem (CKItemsAttributes)

- (NSDictionary *)attributesDictionary {
	return [[NSValueTransformer valueTransformerForName:@"CKDictionaryFromAttributesTransformer"] transformedValue:self.attributes];
}

@end