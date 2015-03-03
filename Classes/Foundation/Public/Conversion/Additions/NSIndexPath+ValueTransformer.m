//
//  NSIndexPath+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSIndexPath+ValueTransformer.h"
#import "NSValueTransformer+Additions.h"


@implementation NSIndexPath (CKValueTransformer)

+ (NSIndexPath*)convertFromNSString:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSUInteger* indexes = malloc(sizeof(NSUInteger) * [components count]);
	
	int i =0;
	for(NSString* component in components){
		indexes[i] = [component integerValue];
		++i;
	}
	
    NSIndexPath *indexPath = [[[NSIndexPath alloc]initWithIndexes:indexes length:[components count]]autorelease];
    free(indexes);
    
    return indexPath;
}

+ (NSString*)convertToNSString:(NSIndexPath*)indexPath{
	NSMutableString* str = [NSMutableString string];
	for(int i =0;i<[indexPath length];++i){
		if(i < [indexPath length] - 1){
			[str appendFormat:@"%lu ",(unsigned long)[indexPath indexAtPosition:i]];
		}
		else{
			[str appendFormat:@"%lu",(unsigned long)[indexPath indexAtPosition:i]];
		}
	}
	return str;
}

@end
