//
//  UIView+Bounce.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/19/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Bounce)

- (void)animateWithBounceFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame duration:(NSTimeInterval)duration
                            update:(void(^)(CGRect frame))update
                        completion:(void(^)(BOOL finished))completion;

- (void)animateWithBounceFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame duration:(NSTimeInterval)duration
                    numberOfBounce:(NSInteger)numberOfBounces damping:(CGFloat)damping
                            update:(void(^)(CGRect frame))update
                        completion:(void(^)(BOOL finished))completion;

- (void)animateWithBounceFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame duration:(NSTimeInterval)duration
                    numberOfBounce:(NSInteger)numberOfBounces numberOfSteps:(NSInteger)steps damping:(CGFloat)damping
                            update:(void(^)(CGRect frame))update
                        completion:(void(^)(BOOL finished))completion;

@end
