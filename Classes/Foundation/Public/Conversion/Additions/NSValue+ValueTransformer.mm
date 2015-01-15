//
//  NSValue+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/13/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import "NSValue+ValueTransformer.h"
#import "CKClassPropertyDescriptor_private.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@implementation NSValue (ValueTransformer)

+ (NSString*)convertToNSString:(NSValue*)value{
    const char * nativeType = [value objCType];
    if(strcmp(nativeType, @encode(CGSize)) == 0){
        return [self convertCGSizeToNSString:value];
    }else if(strcmp(nativeType, @encode(CGPoint)) == 0){
        return [self convertCGPointToNSString:value];
    }else if(strcmp(nativeType, @encode(CGRect)) == 0){
        return [self convertCGRectToNSString:value];
    }else if(strcmp(nativeType, @encode(CGAffineTransform)) == 0){
        return [self convertCGAffineTransformToNSString:value];
    }else if(strcmp(nativeType, @encode(UIEdgeInsets)) == 0){
        return [self convertUIEdgeInsetsToNSString:value];
    }else if(strcmp(nativeType, @encode(CLLocationCoordinate2D)) == 0){
        return [self convertCLLocationCoordinate2DToNSString:value];
    }
    
    CKStructParsedAttributes result = parseStructAttributes([NSString stringWithUTF8String:nativeType]);
    NSString* selectectorName = [NSString stringWithFormat:@"convertFormat_%@_toNSString:",result.structFormat];
    
    SEL selector = NSSelectorFromString(selectectorName);
    
    if(selector && [NSValue respondsToSelector:selector]){
        return [self performSelector:selector];
    }
    
    NSLog(@"Unsupported Conversion of NSValue : %@ with format : %@. Returning empty string.\nPlease implements clas method on NSValue [+(NSString*)%@:(NSValue*)value]",value,result.structFormat,selectectorName);
    
    return @"";
}

+ (NSString*)convertCGSizeToNSString:(NSValue*)value{
    CGSize size;
    [value getValue:&size];
    return [NSString stringWithFormat:@"%g %g",size.width,size.height];
}

+ (NSString*)convertCGPointToNSString:(NSValue*)value{
    CGPoint point;
    [value getValue:&point];
    return [NSString stringWithFormat:@"%g %g",point.x,point.y];
}

+ (NSString*)convertCGRectToNSString:(NSValue*)value{
    CGRect rect;
    [value getValue:&rect];
    return [NSString stringWithFormat:@"%g %g %g %g",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
}

+ (NSString*)convertCGAffineTransformToNSString:(NSValue*)value{
    CGAffineTransform transform;
    [value getValue:&transform];
    return [NSString stringWithFormat:@"%g %g %g %g %g %g",transform.a,transform.b,transform.c,transform.d,transform.tx,transform.ty];
}

+ (NSString*)convertCLLocationCoordinate2DToNSString:(NSValue*)value{
    CLLocationCoordinate2D location;
    [value getValue:&location];
    return [NSString stringWithFormat:@"%g %g",location.latitude,location.longitude];
}

+ (NSString*)convertUIEdgeInsetsToNSString:(NSValue*)value{
    UIEdgeInsets insets;
    [value getValue:&insets];
    return [NSString stringWithFormat:@"%g %g %g %g",insets.top,insets.left,insets.bottom,insets.right];
}

@end
