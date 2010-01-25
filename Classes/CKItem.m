//
//  CKItem.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKItem.h"
#import "CKAttribute.h"

@implementation CKItem

@dynamic name;
@dynamic createdAt;
@dynamic domain;
@dynamic attributes;

@end

@implementation CKItem (CKItemsAccessors)

- (NSDictionary *)attributesAsDictionary {
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	for (CKAttribute *attribute in self.attributes) {
		id object = [result objectForKey:attribute.name];
		
		if (object && [object isKindOfClass:[NSArray class]]) {
			[(NSMutableArray *)object addObject:attribute.value];
		} else if (object) {
			[result setObject:[NSMutableArray arrayWithObjects:object, attribute.value, nil] forKey:attribute.name];
		} else {
			[result setObject:attribute.value forKey:attribute.name];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:result];
}

@end