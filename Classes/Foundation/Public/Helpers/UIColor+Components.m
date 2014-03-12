//
//  UIColor+Components.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/5/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "UIColor+Components.h"

@implementation UIColor (Components)
 
- (CGColorSpaceModel) colorSpaceModel
{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL) canProvideRGBComponents
{
    return (([self colorSpaceModel] == kCGColorSpaceModelRGB) ||
            ([self colorSpaceModel] == kCGColorSpaceModelMonochrome));
}

- (CGFloat) red
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat) green
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
}

- (CGFloat) blue
{
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
}

- (CGFloat) alpha
{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}

@end
