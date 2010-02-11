//
//  CKDictionaryFromAttributesTransformer.m
//  CloudKit
//
//  Created by Fred Brunel on 10-02-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKDictionaryFromAttributesTransformer.h"
#import "CKAttribute.h"

@implementation CKDictionaryFromAttributesTransformer

+ (Class)transformedValueClass {
	return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	for (CKAttribute *attribute in ((NSArray *)value)) {
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
