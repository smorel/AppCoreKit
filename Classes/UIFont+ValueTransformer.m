//
//  UIFont+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIFont+ValueTransformer.h"
#import "CKDebug.h"

@implementation UIFont (CKValueTransformer)

+ (UIFont*)convertFromNSString:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
    return [UIFont convertFromNSArray:components];
}

+ (UIFont*)convertFromNSArray:(NSArray*)ar{
    CKAssert([ar count] == 2,@"Invalid font format");
    NSString* fontName = [ar objectAtIndex:0];
    CGFloat sizeValue = [[ar objectAtIndex:1]floatValue];
    return [UIFont fontWithName:fontName size:sizeValue];
}

+ (NSString*)convertToNSString:(UIFont*)font{
    return [NSString stringWithFormat:@"%@,%.0f",font.fontName,font.pointSize];
}

@end
