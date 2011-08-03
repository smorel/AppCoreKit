//
//  CKNSObject+JSON.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+JSON.h"
#import "CJSONDeserializer.h"

@implementation NSObject (CKNSObjectJSON)

- (id)JSONRepresentation {
	if ([self isKindOfClass:[NSString class]]) {
		return [NSString stringWithFormat:@"\"%@\"", self];
	}
	
	if ([self isKindOfClass:[NSArray class]]) {
		NSMutableArray *JSONRepresentations = [NSMutableArray array];
		
		for (NSObject *object in (NSArray *)self) {
			if ([object respondsToSelector:@selector(JSONRepresentation)]) {
				[JSONRepresentations addObject:[object JSONRepresentation]];
			}
		}

		return [NSString stringWithFormat:@"[%@]", [JSONRepresentations componentsJoinedByString:@","]];
	}
	
	if ([self isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dictionary = (NSDictionary *)self;
		NSMutableArray *JSONPairs = [NSMutableArray array];
		
		for (NSObject *key in [dictionary allKeys]) {
			[JSONPairs addObject:[NSString stringWithFormat:@"%@:%@", [key JSONRepresentation], [[dictionary objectForKey:key] JSONRepresentation]]];
		}
		
		return [NSString stringWithFormat:@"{%@}", [JSONPairs componentsJoinedByString:@","]];
	}
	
	if ([self isKindOfClass:[NSNumber class]]) {
		return [(NSNumber *)self stringValue];
	}
	
	return [NSNull null];
}

+ (id)objectFromJSONData:(NSData *)data {
	return [[CJSONDeserializer deserializer] deserialize:data error:nil];
}
+ (id)objectFromJSONData:(NSData *)data error:(NSError **)error {
	return [[CJSONDeserializer deserializer] deserialize:data error:error];
}

@end
