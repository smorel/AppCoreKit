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

+ (CGSize)parseDictionaryToCGSize:(NSDictionary*)dictionary{
    id width = [dictionary objectForKey:@"width"];
    id height = [dictionary objectForKey:@"height"];
	return CGSizeMake(width ? [width floatValue] : 0,height ? [height floatValue] : 0);
}

+ (CGSize)convertCGSizeFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGSize size = [NSValueTransformer parseStringToCGSize:object];
		return size;
	}else if([object isKindOfClass:[NSDictionary class]]){
        CGSize size = [NSValueTransformer parseDictionaryToCGSize:object];
		return size;
    }else if([object isKindOfClass:[NSValue class]]){
        return [object CGSizeValue];
    }
	CKAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGSizeMake(10,10) : [object CGSizeValue];
}

+ (CGPoint)parseStringToCGPoint:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 2,@"invalid point format");
	return CGPointMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}

+ (CGPoint)parseDictionaryToCGPoint:(NSDictionary*)dictionary{
    id x = [dictionary objectForKey:@"x"];
    id y = [dictionary objectForKey:@"y"];
	return CGPointMake(x ? [x floatValue] : 0,y ? [y floatValue] : 0);
}

+ (CGPoint)convertCGPointFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGPoint point = [NSValueTransformer parseStringToCGPoint:object];
		return point;
	}else if([object isKindOfClass:[NSDictionary class]]){
        CGPoint point = [NSValueTransformer parseDictionaryToCGPoint:object];
		return point;
    }else if([object isKindOfClass:[NSValue class]]){
        return [object CGPointValue];
    }
	CKAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGPointMake(10,10) : [object CGPointValue];
}

+ (CGRect)parseStringToCGRect:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 4,@"invalid rect format");
	return CGRectMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue],[[components objectAtIndex:2]floatValue],[[components objectAtIndex:3]floatValue]);
}

+ (CGRect)parseDictionaryToCGRect:(NSDictionary*)dictionary{
    id origin = [dictionary objectForKey:@"origin"];
    id size = [dictionary objectForKey:@"size"];
    
    CGPoint p = origin ? [self convertCGPointFromObject:origin] : CGPointMake(0,0);
    CGSize s  = size   ? [self convertCGSizeFromObject:size]    : CGSizeMake(0,0);
    
    return CGRectMake(p.x,p.y,s.width,s.height);
}

+ (CGRect)convertCGRectFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGRect rect = [NSValueTransformer parseStringToCGRect:object];
		return rect;
	}else if([object isKindOfClass:[NSDictionary class]]){
        CGRect rect = [NSValueTransformer parseDictionaryToCGRect:object];
		return rect;
    }else if([object isKindOfClass:[NSValue class]]){
        return [object CGRectValue];
    }
	CKAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGRectMake(0,0,10,10) : [object CGRectValue];
}

+ (UIEdgeInsets)parseStringToUIEdgeInsets:(NSString*)str{
    NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 4,@"invalid insets format");
	return UIEdgeInsetsMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue],[[components objectAtIndex:2]floatValue],[[components objectAtIndex:3]floatValue]);
}

+ (UIEdgeInsets)parseDictionaryToUIEdgeInsets:(NSDictionary*)dictionary{
    id top = [dictionary objectForKey:@"top"];
    id left = [dictionary objectForKey:@"left"];
    id bottom = [dictionary objectForKey:@"bottom"];
    id right = [dictionary objectForKey:@"right"];
    
    return UIEdgeInsetsMake(top ? [top floatValue] : 0, left ? [left floatValue] : 0, bottom ? [bottom floatValue] : 0, right ? [right floatValue] : 0);
}

+ (UIEdgeInsets)convertUIEdgeInsetsFromObject:(id)object{
    if([object isKindOfClass:[NSString class]]){
		UIEdgeInsets insets = [NSValueTransformer parseStringToUIEdgeInsets:object];
		return insets;
	}else if([object isKindOfClass:[NSDictionary class]]){
        UIEdgeInsets insets = [NSValueTransformer parseDictionaryToUIEdgeInsets:object];
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

+ (CGFloat)degreeToRadian:(CGFloat)degree{
    return degree * M_PI / 180.0f;
}

+ (CGFloat)parseRotationAngleFromObject:(id)rotation{
    if([rotation isKindOfClass:[NSNumber class]]){
        return [self degreeToRadian:[rotation floatValue]];
    }else if([rotation isKindOfClass:[NSString class]]){
        return [self degreeToRadian:[rotation floatValue]];
    }
    return 0;
}

+ (CGAffineTransform)parseDictionaryToCGAffineTransform:(NSDictionary*)dictionary{
    id rotation = [dictionary objectForKey:@"rotation"];
    
    id translation = [dictionary objectForKey:@"translation"];
    id scale = [dictionary objectForKey:@"scale"];
    
    CGFloat r = [self parseRotationAngleFromObject:rotation];
    CGPoint t = translation ? [self convertCGPointFromObject:translation] : CGPointMake(0, 0);
    CGPoint s = scale ? [self convertCGPointFromObject:scale] : CGPointMake(1,1);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, t.x, t.y);
    transform = CGAffineTransformRotate(transform, r);
    transform = CGAffineTransformScale(transform, s.x, s.y);
	return transform;
}

+ (CGAffineTransform)parseStringToCGAffineTransform:(NSString*)str{
    NSArray* components = [str componentsSeparatedByString:@" "];
	CKAssert([components count] == 6,@"invalid size format");
	return CGAffineTransformMake([components[0]floatValue], [components[1]floatValue], [components[2]floatValue], [components[3]floatValue], [components[4]floatValue], [components[5]floatValue]);
}

+ (CGAffineTransform)convertCGAffineTransformFromObject:(id)object{
    if([object isKindOfClass:[NSDictionary class]]){
		CGAffineTransform t = [NSValueTransformer parseDictionaryToCGAffineTransform:object];
		return t;
	}
    else if([object isKindOfClass:[NSValue class]]){
        CGAffineTransform t;
        [object getValue:&t];
        return t;
    }else if([object isKindOfClass:[NSString class]]){
		CGAffineTransform t = [NSValueTransformer parseStringToCGAffineTransform:object];
		return t;
    }
	return CGAffineTransformIdentity;
}

@end
