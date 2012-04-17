//
//  CKUIColor+Additions.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-12.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** TODO
 */
@interface UIColor (CKUIColorAdditions)

+ (UIColor *)colorWithRGBValue:(NSUInteger)value;
+ (UIColor *)blueTextColor;

- (UIColor *)RGBColor;
+ (UIColor *)colorWithGradientWithColors:(NSArray *)colors colorLocations:(CGFloat *)locations size:(CGSize)size;
+ (UIColor *)colorWithGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor size:(CGSize)size;
+ (UIColor *)colorWithVerticalGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor height:(CGFloat)height;


+ (UIImage *)imageWithGradientWithColors:(NSArray *)colors colorLocations:(CGFloat *)locations size:(CGSize)size;

@end
