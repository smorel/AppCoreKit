//
//  CKAttributesDictionary.m
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKAttributesDictionary.h"
#import "CKItem.h"

@implementation CKAttributesDictionary

- (id)initWithItem:(CKItem *)item {
	if (self = [super init]) {
		_item = [item retain];
	}
	return self;
}

- (void)dealloc {
	[_item release];
	[_attributes release];
	[super dealloc];
}

//

- (void)ensureFetchAttributes {
	if (_attributes) { return; }
	_attributes = [[[NSValueTransformer valueTransformerForName:@"CKDictionaryFromAttributesTransformer"] transformedValue:_item.attributes] retain];
}

//

- (NSUInteger)count {
	return _item.attributes.count;
}

- (id)objectForKey:(id)key {
	[self ensureFetchAttributes];
	return [_attributes objectForKey:key];
}

- (NSEnumerator *)keyEnumerator {
	[self ensureFetchAttributes];
	return [_attributes keyEnumerator];
}

@end
