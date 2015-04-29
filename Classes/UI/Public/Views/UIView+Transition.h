//
//  UIView+Transition.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Transition)

- (UIView*)transitionSnapshot;
- (UIView*)transitionSnapshotAfterUpdate;

- (void)setStyleViewsDecoratorsEnabled:(BOOL)enabled;

@end
