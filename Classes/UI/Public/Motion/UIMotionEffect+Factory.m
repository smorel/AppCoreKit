//
//  UIMotionEffect+Factory.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-06.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIMotionEffect+Factory.h"

@implementation CKParallaxMotionEffect

- (void)setOffset:(CGSize)offset{
    _offset = offset;
    
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[[UIInterpolatingMotionEffect alloc]
      initWithKeyPath:@"center.y"
      type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis]autorelease];
    verticalMotionEffect.minimumRelativeValue = @(_offset.height);
    verticalMotionEffect.maximumRelativeValue = @(-_offset.height);
    
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[[UIInterpolatingMotionEffect alloc]
      initWithKeyPath:@"center.x"
      type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis]autorelease];
    horizontalMotionEffect.minimumRelativeValue = @(_offset.width);
    horizontalMotionEffect.maximumRelativeValue = @(-_offset.width);
    
    self.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
}

@end



@implementation UIMotionEffect (Factory)

+ (UIMotionEffect*)parallaxMotionEffectWithOffset:(CGFloat)offset{
    CKParallaxMotionEffect* effect = [[[CKParallaxMotionEffect alloc]init]autorelease];
    effect.offset = CGSizeMake(offset,offset);
    return effect;
}

@end
