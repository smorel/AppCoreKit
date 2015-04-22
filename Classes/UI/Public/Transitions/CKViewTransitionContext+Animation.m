//
//  CKViewTransitionContext+Animation.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-22.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext+Animation.h"

@implementation CKViewTransitionContext (Animation)


+ (UICollectionViewLayoutAttributes*)attributesFromAttributes:(UICollectionViewLayoutAttributes*)fromAttributes
                                                    animation:(CKViewTransitionContextAnimation)animation
                                                       insets:(UIEdgeInsets)insets
                                            transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    UICollectionViewLayoutAttributes* att = [[[UICollectionViewLayoutAttributes alloc]init]autorelease];
    att.transform = CGAffineTransformIdentity;
    if(animation == CKViewTransitionContextAnimationFadeIn){
        att.frame = fromAttributes.frame;
        fromAttributes.alpha = 0.0f;
        att.alpha = 1.0f;
    }else if(animation == CKViewTransitionContextAnimationFadeOut){
        att.frame = fromAttributes.frame;
        fromAttributes.alpha = 1.0f;
        att.alpha = 0.0f;
    }else if(animation == CKViewTransitionContextAnimationSlideTop){
        att.frame = CGRectMake(fromAttributes.frame.origin.x,
                               -fromAttributes.frame.size.height,
                               fromAttributes.frame.size.width,
                               fromAttributes.frame.size.height);
    }else if(animation == CKViewTransitionContextAnimationSlideBottom){
        att.frame = CGRectMake([transitionContext containerView].bounds.size.width / 2.0f - fromAttributes.frame.size.width / 2.0f,
                               [transitionContext containerView].bounds.size.height,
                               fromAttributes.frame.size.width,
                               fromAttributes.frame.size.height);
    }else if(animation == CKViewTransitionContextAnimationSlideLeft){
        att.frame = CGRectMake(fromAttributes.frame.origin.x - fromAttributes.frame.size.width,
                               fromAttributes.frame.origin.y,
                               fromAttributes.frame.size.width,
                               fromAttributes.frame.size.height);
    }else if(animation == CKViewTransitionContextAnimationSlideRight){
        att.frame = CGRectMake(fromAttributes.frame.origin.x + fromAttributes.frame.size.width,
                               fromAttributes.frame.origin.y,
                               fromAttributes.frame.size.width,
                               fromAttributes.frame.size.height);
    }else if(animation == CKViewTransitionContextAnimationNone){
        att.frame = fromAttributes.frame;
    }else if(animation == CKViewTransitionContextAnimationFill){
        att.frame = [transitionContext containerView].bounds;
    }

    return [self attributesWithAttributes:att insets:insets];
}

+ (UICollectionViewLayoutAttributes*)attributesWithAttributes:(UICollectionViewLayoutAttributes*)fromAttributes
                                                       insets:(UIEdgeInsets)insets{
    UICollectionViewLayoutAttributes* att = [fromAttributes copy];
    
    CGRect rect = att.frame;
    rect.origin.x += insets.left;
    rect.origin.y += insets.top;
    rect.size.width -= (insets.left + insets.right);
    rect.size.height -= (insets.top + insets.bottom);
    
    att.frame = rect;

    return att;
}

+ (UICollectionViewLayoutAttributes*)attributesFromAttributes:(UICollectionViewLayoutAttributes*)fromAttributes
                                                  animation:(CKViewTransitionContextAnimation)animation
                                          transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
    return [self attributesFromAttributes:fromAttributes animation:animation insets:UIEdgeInsetsMake(0, 0, 0, 0) transitionContext:transitionContext];
    
}


@end
