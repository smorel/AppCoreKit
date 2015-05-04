//
//  UIView+Transition.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Transition)

- (UIView*)transitionSnapshotWithoutViewHierarchy;
- (UIView*)transitionSnapshotWithViewHierarchy;

- (void)setEffectViewsEnabled:(BOOL)enabled;

@end
