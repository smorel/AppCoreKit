//
//  UIColor+Components.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/5/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "UIColor+Components.h"

@implementation UIColor (Components)
 
/*- (CGColorSpaceModel) colorSpaceModel
{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL) canProvideRGBComponents
{
    return (([self colorSpaceModel] == kCGColorSpaceModelRGB) ||
            ([self colorSpaceModel] == kCGColorSpaceModelMonochrome));
}
 */

- (CGFloat) red
{
    
    CGFloat r =0, g = 0, b = 0, a =0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return r;
    
    /*
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
     */
}

- (CGFloat) green
{
    
    CGFloat r =0, g = 0, b = 0, a =0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return g;
    
    /*
    NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
     */
}

- (CGFloat) blue
{
    CGFloat r =0, g = 0, b = 0, a =0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return b;
    
    /*NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use -red, -green, -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
     */
}

- (CGFloat) alpha
{
    CGFloat r =0, g = 0, b = 0, a =0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return a;
    
    //const CGFloat *c = CGColorGetComponents(self.CGColor);
    //return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}



- (CGFloat) hue{
    CGFloat h =0, s = 0, v = 0, a =0;
    [self getHue:&h saturation:&s brightness:&v alpha:&a];
    return h;
}

- (CGFloat) saturation{
    CGFloat h =0, s = 0, v = 0, a =0;
    [self getHue:&h saturation:&s brightness:&v alpha:&a];
    return s;
}

- (CGFloat) brightness{
    CGFloat h =0, s = 0, v = 0, a =0;
    [self getHue:&h saturation:&s brightness:&v alpha:&a];
    return v;
}

+ (UIColor*)colorWithColor:(UIColor*)color intensity:(CGFloat)intensity{
    return [UIColor colorWithHue:color.hue saturation:color.saturation brightness:(color.brightness * intensity) alpha:color.alpha];
}

@end
