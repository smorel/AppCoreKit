//
//  UIMotionEffect+Factory.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-06.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIMotionEffect+Factory.h"

@implementation UIMotionEffect (Factory)

+ (UIMotionEffect*)parallaxMotionEffectWithOffset:(CGFloat)offset{
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(offset);
    verticalMotionEffect.maximumRelativeValue = @(-offset);
    
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(offset);
    horizontalMotionEffect.maximumRelativeValue = @(-offset);
    
    // Create group to combine both
    UIMotionEffectGroup* motionEffectGroup = [UIMotionEffectGroup new];
    motionEffectGroup.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    return motionEffectGroup;
}

@end
