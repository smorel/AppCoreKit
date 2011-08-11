//
//  CKNSValueTransformer+CGTypes.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSValueTransformer+CGTypes.h"
#import "CKNSValueTransformer+Additions.h"


@implementation NSValueTransformer (CKCGTypes)


+ (CGSize)parseStringToCGSize:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 2,@"invalid size format");
	return CGSizeMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}


+ (CGSize)convertCGSizeFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGSize size = [NSValueTransformer parseStringToCGSize:object];
		return size;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGSizeMake(10,10) : [object CGSizeValue];
}

+ (CGRect)parseStringToCGRect:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 4,@"invalid rect format");
	return CGRectMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue],[[components objectAtIndex:2]floatValue],[[components objectAtIndex:3]floatValue]);
}

+ (CGRect)convertCGRectFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGRect rect = [NSValueTransformer parseStringToCGRect:object];
		return rect;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGRectMake(0,0,10,10) : [object CGRectValue];
}

+ (CGPoint)parseStringToCGPoint:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 2,@"invalid point format");
	return CGPointMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}

+ (CGPoint)convertCGPointFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGPoint point = [NSValueTransformer parseStringToCGPoint:object];
		return point;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGPointMake(10,10) : [object CGPointValue];
}

@end
