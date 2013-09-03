//
//  UIButton+FlatDesign.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-30.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (FlatDesign)
@property(nonatomic,retain) UIColor* defaultBackgroundColor;
@property(nonatomic,retain) UIColor* highlightedBackgroundColor;
@property(nonatomic,retain) UIColor* disabledBackgroundColor;
@property(nonatomic,retain) UIColor* selectedBackgroundColor;

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *)backgroundColorForState:(UIControlState)state;

@end
