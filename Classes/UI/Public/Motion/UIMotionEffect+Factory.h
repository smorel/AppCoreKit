//
//  UIMotionEffect+Factory.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-06.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface CKParallaxMotionEffect : UIMotionEffectGroup

/**
 */
@property(nonatomic,assign) CGSize offset;

@end


/**
 */
@interface UIMotionEffect (Factory)

/**
 */
+ (UIMotionEffect*)parallaxMotionEffectWithOffset:(CGFloat)offset;

@end
