//
//  CKViewTransitionContext+Animation.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-22.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKViewTransitionContext.h"

typedef NS_ENUM(NSInteger, CKViewTransitionContextAnimation){
    CKViewTransitionContextAnimationNone,
    CKViewTransitionContextAnimationFadeIn,
    CKViewTransitionContextAnimationFadeOut,
    CKViewTransitionContextAnimationSlideTop,
    CKViewTransitionContextAnimationSlideBottom,
    CKViewTransitionContextAnimationSlideLeft,
    CKViewTransitionContextAnimationSlideRight,
    CKViewTransitionContextAnimationFill
};


@interface CKViewTransitionContext (Animation)

+ (UICollectionViewLayoutAttributes*)attributesFromAttributes:(UICollectionViewLayoutAttributes*)fromAttributes
                                                  animation:(CKViewTransitionContextAnimation)animation
                                          transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

+ (UICollectionViewLayoutAttributes*)attributesFromAttributes:(UICollectionViewLayoutAttributes*)fromAttributes
                                                    animation:(CKViewTransitionContextAnimation)animation
                                                       insets:(UIEdgeInsets)insets
                                            transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext;

+ (UICollectionViewLayoutAttributes*)attributesWithAttributes:(UICollectionViewLayoutAttributes*)fromAttributes
                                                       insets:(UIEdgeInsets)insets;

@end
