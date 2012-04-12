//
//  CKNSDate+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSDate+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSDate+Conversions.h"


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
