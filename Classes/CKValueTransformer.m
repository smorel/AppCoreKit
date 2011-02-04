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

	//return the object hopping there is autoConversion :)
	return value;
}

@end
