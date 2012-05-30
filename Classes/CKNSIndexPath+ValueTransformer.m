//
//  CKNSIndexPath+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSIndexPath+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"


@implementation NSIndexPath (CKValueTransformer)

+ (NSIndexPath*)convertFromNSString:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSUInteger* indexes = malloc(sizeof(NSUInteger) * [components count]);
	
	int i =0;
	for(NSString* component in components){
		indexes[i] = [component intValue];
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
			[str appendFormat:@"%d ",[indexPath indexAtPosition:i]];
		}
		else{
			[str appendFormat:@"%d",[indexPath indexAtPosition:i]];
		}
	}
	return str;
}

@end
