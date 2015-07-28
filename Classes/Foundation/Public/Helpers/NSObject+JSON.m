//
//  NSObject+JSON.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "NSObject+JSON.h"
#import "JSONKit.h"
#import "NSObject+Runtime.h"
#import "NSValueTransformer+Additions.h"

@implementation NSObject (CKNSObjectJSON)

- (id)JSONRepresentation {
	if ([self isKindOfClass:[NSString class]]) {
		return [NSString stringWithFormat:@"\"%@\"", [(NSString*)self stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]];
	}
	
	else if ([self isKindOfClass:[NSArray class]]) {
		NSMutableArray *JSONRepresentations = [NSMutableArray array];
		
		for (NSObject *object in (NSArray *)self) {
			if ([object respondsToSelector:@selector(JSONRepresentation)]) {
				[JSONRepresentations addObject:[object JSONRepresentation]];
			}
		}

		return [NSString stringWithFormat:@"[%@]", [JSONRepresentations componentsJoinedByString:@","]];
	}
	
	else if ([self isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dictionary = (NSDictionary *)self;
		NSMutableArray *JSONPairs = [NSMutableArray array];
		
		for (NSObject *key in [dictionary allKeys]) {
			[JSONPairs addObject:[NSString stringWithFormat:@"%@:%@", [key JSONRepresentation], [[dictionary objectForKey:key] JSONRepresentation]]];
		}
		
		return [NSString stringWithFormat:@"{%@}", [JSONPairs componentsJoinedByString:@","]];
	}
	
	else if ([self isKindOfClass:[NSNumber class]]) {
		return [(NSNumber *)self stringValue];
	}
    
    else if( [self isKindOfClass:[NSObject class]] ){
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for(CKClassPropertyDescriptor* descriptor in [self allPropertyDescriptors]){
            id value =[self valueForKey:descriptor.name];
            CKProperty* property = [CKProperty propertyWithObject:self keyPath:descriptor.name];
            
            id json  = nil;
            if([property isNumber]){
                json = [NSValueTransformer transformProperty:property toClass:[NSNumber class]];
            }else{
                json = [NSValueTransformer transformProperty:property toClass:[NSString class]];
            }
            
            if(!json){
                json = [value JSONRepresentation];
            }
            
            [dictionary setObject:json forKey:descriptor.name];
        }
        return dictionary;
    }
	
	return @"null";
}

+ (id)objectFromJSONData:(NSData *)data {
	return [NSObject objectFromJSONData:data error:nil];
}
+ (id)objectFromJSONData:(NSData *)data error:(NSError **)error {
	return [data objectFromJSONDataWithParseOptions:JKParseOptionValidFlags error:error];
}

@end
