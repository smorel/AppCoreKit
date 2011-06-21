//
//  CKUIColorAdditions.m
//  CloudKit
//
//  Created by Fred Brunel on 10-02-12.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUIColorAdditions.h"

@implementation UIColor (CKUIColorAdditions)

+ (UIColor *)colorWithRGBValue:(NSUInteger)value {
	return [UIColor colorWithRed:((value & 0xFF0000) >> 16) / 255.0
						   green:((value & 0xFF00) >> 8) / 255.0
							blue:(value & 0xFF) / 255.0
						   alpha:1.0];
}

+ (UIColor *)blueTextColor {
	return [UIColor colorWithRGBValue:0x385487];
}

- (UIColor *)RGBColor {
	CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
	
	switch (model) {
		case kCGColorSpaceModelRGB:
			return self;
			break;
		case kCGColorSpaceModelMonochrome: {
			const CGFloat *comps = CGColorGetComponents(self.CGColor);
			return [UIColor colorWithRed:comps[0] green:comps[0] blue:comps[0] alpha:comps[1]];
			break;
		}
			
		default:
			NSAssert(FALSE, @"CGColorSpaceModel (%d) not supported.", model);
			break;
	}	
	
	return nil;
}

+ (UIColor *)colorWithGradientWithColors:(NSArray *)colors colorLocations:(CGFloat *)locations size:(CGSize)size {	
	return [UIColor colorWithPatternImage:[UIColor imageWithGradientWithColors:colors colorLocations:locations size:size]];
}

+ (UIColor *)colorWithGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor size:(CGSize)size {
	CGFloat colorLocations[2];
	colorLocations[0] = 0.0f;
	colorLocations[1] = 1.0f;	
	return [UIColor colorWithGradientWithColors:[NSArray arrayWithObjects:fromColor, toColor, nil] colorLocations:colorLocations size:size];
}

+ (UIColor *)colorWithVerticalGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor height:(CGFloat)height {
	return [UIColor colorWithGradientFromColor:fromColor toColor:toColor size:CGSizeMake(1, height)];
}

+ (UIImage *)imageWithGradientWithColors:(NSArray *)colors colorLocations:(CGFloat *)locations size:(CGSize)size {	
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, 4 * size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
	
	NSMutableArray *gradientColors = [NSMutableArray array];
	for (UIColor *color in colors) {
		[gradientColors addObject:(id)([color RGBColor].CGColor)];
	}
	
	CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)gradientColors, locations);
	
	CGContextDrawLinearGradient(bitmapContext, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0, size.height), 0);
	CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
	UIImage *gradientImage = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGContextRelease(bitmapContext);
	
	return gradientImage;
}

@end
