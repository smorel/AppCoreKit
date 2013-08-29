//
//  NSDate+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSDate+ValueTransformer.h"
#import "NSValueTransformer+Additions.h"
#import "NSDate+Conversions.h"


@implementation NSDate (CKValueTransformer)

+ (NSDate*)convertFromNSString:(NSString*)str withFormat:(NSString*)format{//special case to handle with attributes
	return [NSDate dateFromString:str withDateFormat:format];
}

+ (NSString*)convertToNSString:(NSDate*)date withFormat:(NSString*)format{
	return [NSDate stringFromDate:date withDateFormat:format];
}

+ (NSDate*)convertFromNSString:(NSString*)str{
	return [NSDate dateFromString:str withDateFormat:@"dd MMMM yyyy"];
}

+ (NSString*)convertToNSString:(NSDate*)date{
	return [NSDate stringFromDate:date withDateFormat:@"dd MMMM yyyy"];
}

@end
