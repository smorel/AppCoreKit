//
//  CKStyle+Parsing.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyle+Parsing.h"
#import "CKUIColorAdditions.h"

//TODO : HERE store the converted data in the key to convert only once !

@implementation NSMutableDictionary (CKStyleParsing)

- (UIColor*) colorForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[UIColor class]]){
		return object;
	}
	id result = [NSValueTransformer transform:object toClass:[UIColor class]];
	if(result){
		[self setObject:result forKey:key];
	}
	return result;
}

- (NSArray*) colorArrayForKey:(NSString*)key{
	id object = [self objectForKey:key];
	id result = [NSArray convertFromNSArray:object withContentClassName:@"UIColor"];
	if(result){
		[self setObject:result forKey:key];
	}
	return result;
}

- (NSArray*) cgFloatArrayForKey:(NSString*)key{
	id object = [self objectForKey:key];
	id result = [NSArray convertFromNSArray:object withContentClassName:@"NSNumber"];
	if(result){
		[self setObject:result forKey:key];
	}
	return result;
}

- (UIImage*) imageForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[UIImage class]]){
		return object;
	}
	id result = [NSValueTransformer transform:object toClass:[UIImage class]];
	if(result){
		[self setObject:result forKey:key];
	}	return result;
}

- (NSInteger) enumValueForKey:(NSString*)key withDictionary:(NSDictionary*)dictionary{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSNumber class]]){
		return [object intValue];
	}
	NSInteger result = [NSValueTransformer convertEnumFromObject:object withEnumDefinition:dictionary];
	[self setObject:[NSNumber numberWithInt:result] forKey:key];
	return result;
}

- (CGSize) cgSizeForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSValue class]]){
		return [object CGSizeValue];
	}
	CGSize result = [NSValueTransformer convertCGSizeFromObject:object];
	[self setObject:[NSValue valueWithCGSize:result] forKey:key];
	return result;	
}

- (CGFloat) cgFloatForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSNumber class]]){
		return [object floatValue];
	}
	CGFloat result = [NSValueTransformer convertFloatFromObject:object];
	[self setObject:[NSNumber numberWithFloat:result] forKey:key];
	return result;	
}


- (NSString*) stringForKey:(NSString*)key{
	id object = [self objectForKey:key];
	NSAssert(object == nil || [object isKindOfClass:[NSString class]],@"invalid class for string");
	return (NSString*)object;
}

- (NSInteger) integerForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSNumber class]]){
		return [object intValue];
	}
	NSInteger result = [NSValueTransformer convertIntegerFromObject:object];
	[self setObject:[NSNumber numberWithInt:result] forKey:key];
	return result;	
}

@end