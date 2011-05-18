//
//  CKConverter.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-22.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKValueTransformer.h"
#import "CKNSObject+Introspection.h"

@implementation CKValueTransformer

static NSNumberFormatter* CKValueTransformerNumberFormatter = nil;

+ (id)transformValue:(id)value toClass:(Class)type{
	if([value isKindOfClass:type])
		return value;
	
	if(CKValueTransformerNumberFormatter == nil){
		CKValueTransformerNumberFormatter = [[NSNumberFormatter alloc] init];
	}
	
	//Handle Number to string and String to number 
	if([value isKindOfClass:[NSNumber class]]
		&& [NSObject isKindOf:type parentType:[NSString class]])
	{
			NSString* n = [CKValueTransformerNumberFormatter stringFromNumber:value]; 
		    return n;
	}
	else if([value isKindOfClass:[NSString class]]
		&& [NSObject isKindOf:type parentType:[NSNumber class]]){
			NSNumber* s = [CKValueTransformerNumberFormatter numberFromString:value];  
			return s;
	}
	else if([value isKindOfClass:[NSURL class]]
			&& [NSObject isKindOf:type parentType:[NSString class]]){
		NSURL* url = (NSURL*)value;
		return [NSString stringWithFormat:@"%@:%@",[url scheme], [url resourceSpecifier]];
	}
	else if([value isKindOfClass:[NSString class]]
			&& [NSObject isKindOf:type parentType:[NSURL class]]){
		NSString* str = (NSString*)value;
		return [NSURL URLWithString:str];
	}
	else if(value == nil || [value isKindOfClass:[NSNull class]]){
		if([NSObject isKindOf:type parentType:[NSURL class]])
			return [NSURL URLWithString:@""];
		else if ([NSObject isKindOf:type parentType:[NSString class]])
			return @"";
		else if([NSObject isKindOf:type parentType:[NSNumber class]])
			return [NSNumber numberWithInt:0];
	}
	else if([value isKindOfClass:[NSIndexPath class]]
			&& [NSObject isKindOf:type parentType:[NSString class]])
	{
		NSMutableString* str = [NSMutableString stringWithCapacity:124];
		NSIndexPath* indexPath = (NSIndexPath*)value;
		for(int i=0;i<[indexPath length];++i){
			if(i < [indexPath length] - 1){
				[str appendFormat:@"%d ",[indexPath indexAtPosition:i]];
			}
			else{
				[str appendFormat:@"%d",[indexPath indexAtPosition:i]];
			}
		}
		
		return str;
	}

	//return the object hopping there is autoConversion :)
	return value;
}

@end
