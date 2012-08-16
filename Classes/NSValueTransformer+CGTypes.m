//
//  NSValueTransformer+CGTypes.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSValueTransformer+CGTypes.h"
#import "NSValueTransformer+Additions.h"
#import "UIColor+ValueTransformer.h"

#import "UIColor+ValueTransformer.h"
#import "UIImage+ValueTransformer.h"
#import "NSNumber+ValueTransformer.h"
#import "NSURL+ValueTransformer.h"
#import "NSDate+ValueTransformer.h"
#import "NSArray+ValueTransformer.h"
#import "CKCollection+ValueTransformer.h"
#import "NSIndexPath+ValueTransformer.h"
#import "NSObject+ValueTransformer.h"
#import "NSValueTransformer+NativeTypes.h"
#import "NSValueTransformer+CGTypes.h"

#import "CKDebug.h"

@implementation NSValueTransformer (CKCGTypes)


+ (CGSize)parseStringToCGSize:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 2,@"invalid size format");
	return CGSizeMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}


+ (CGSize)convertCGSizeFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGSize size = [NSValueTransformer parseStringToCGSize:object];
		return size;
	}
	CKAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGSizeMake(10,10) : [object CGSizeValue];
}

+ (CGRect)parseStringToCGRect:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 4,@"invalid rect format");
	return CGRectMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue],[[components objectAtIndex:2]floatValue],[[components objectAtIndex:3]floatValue]);
}

+ (CGRect)convertCGRectFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGRect rect = [NSValueTransformer parseStringToCGRect:object];
		return rect;
	}
	CKAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGRectMake(0,0,10,10) : [object CGRectValue];
}

+ (CGPoint)parseStringToCGPoint:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 2,@"invalid point format");
	return CGPointMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}

+ (CGPoint)convertCGPointFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGPoint point = [NSValueTransformer parseStringToCGPoint:object];
		return point;
	}
	CKAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGPointMake(10,10) : [object CGPointValue];
}

+ (UIEdgeInsets)parseStringToUIEdgeInsets:(NSString*)str{
    NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 4,@"invalid insets format");
	return UIEdgeInsetsMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue],[[components objectAtIndex:2]floatValue],[[components objectAtIndex:3]floatValue]);
}

+ (UIEdgeInsets)convertUIEdgeInsetsFromObject:(id)object{
    if([object isKindOfClass:[NSString class]]){
		UIEdgeInsets insets = [NSValueTransformer parseStringToUIEdgeInsets:object];
		return insets;
	}else if([object isKindOfClass:[NSValue class]]){
        return [object UIEdgeInsetsValue];
    }
	return UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (CGColorRef)convertCGColorRefFromObject:(id)object{
    UIColor* color = [UIColor convertFromObject:object];
    return [color CGColor];
}

+ (CLLocationCoordinate2D)parseStringToCLCoordinate2D:(NSString*)str{
    NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 2,@"invalid CLLocationCoordinate2D string format");
	return CLLocationCoordinate2DMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}

+ (CLLocationCoordinate2D)convertCLLocationCoordinate2DFromObject:(id)object{
    if([object isKindOfClass:[NSString class]]){
		CLLocationCoordinate2D point = [NSValueTransformer parseStringToCLCoordinate2D:object];
		return point;
	}
    else if([object isKindOfClass:[NSValue class]]){
        CLLocationCoordinate2D c;
        [object getValue:&c];
        return c;
    }
	return CLLocationCoordinate2DMake(0,0);
}

@end
