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

+ (id)transformValue:(id)value toClass:(Class)type{
	if([value isKindOfClass:type])
		return value;
	
	//Handle Number to string and String to number 
	if([value isKindOfClass:[NSNumber class]]
		&& [NSObject isKindOf:type parentType:[NSString class]])
	{
			NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init]autorelease];
			NSString* n = [numberFormatter stringFromNumber:value]; 
		    return n;
	}
	else if([value isKindOfClass:[NSString class]]
		&& [NSObject isKindOf:type parentType:[NSNumber class]]){
			NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init]autorelease];
			NSNumber* s = [numberFormatter numberFromString:value];  
			return s;
	}

	//return the object hopping there is autoConversion :)
	return value;
}

@end
