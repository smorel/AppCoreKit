//
//  CKNSNumber+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSNumber+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"


static NSNumberFormatter* CKValueTransformerNumberFormatter = nil;

@implementation NSNumber (CKValueTransformer)

+ (NSNumber*)convertFromNSString:(NSString*)str{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKValueTransformerNumberFormatter = [[NSNumberFormatter alloc] init];
		[CKValueTransformerNumberFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    });
	return [CKValueTransformerNumberFormatter numberFromString:str]; 
}

+ (NSString*)convertToNSString:(NSNumber*)n{
	/*if(CKValueTransformerNumberFormatter == nil){
     CKValueTransformerNumberFormatter = [[NSNumberFormatter alloc] init];
     [CKValueTransformerNumberFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
     }
     return [CKValueTransformerNumberFormatter stringFromNumber:n];*/
	return [NSString stringWithFormat:@"%g",[n floatValue]];
}

@end
