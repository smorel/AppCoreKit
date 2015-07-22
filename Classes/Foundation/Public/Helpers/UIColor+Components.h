//
//  UIColor+Components.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/5/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Components)
@property(nonatomic,readonly) CGFloat red;
@property(nonatomic,readonly) CGFloat green;
@property(nonatomic,readonly) CGFloat blue;
@property(nonatomic,readonly) CGFloat alpha;

@property(nonatomic,readonly) CGFloat hue;
@property(nonatomic,readonly) CGFloat saturation;
@property(nonatomic,readonly) CGFloat brightness;

/** Returns a dimmed color with intensity between 0 and 1
 */
+ (UIColor*)colorWithColor:(UIColor*)color intensity:(CGFloat)intensity;

@end
