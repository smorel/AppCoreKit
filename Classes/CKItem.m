//
//  CKItem.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKItem.h"
#import "CKAttribute.h"
#import "CKAttributesDictionary.h"

@implementation CKItem

@dynamic name;
@dynamic createdAt;
@dynamic domain;
@dynamic attributes;

@end

@implementation CKItem (CKItemsRepresentation)

- (NSDictionary *)propertyListRepresentation {
	return [[[CKAttributesDictionary alloc] initWithItem:self] autorelease];
}

- (NSDictionary *)attributesDictionary {
	return [self propertyListRepresentation];
}

@end