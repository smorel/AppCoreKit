//
//  UISlider+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-31.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "UISlider+Style.h"


@implementation UISlider (Style)

@dynamic defaultThumbImage,selectedThumbImage,disabledThumbImage,highlightedThumbImage,
defaultMinimumTrackImage,selectedMinimumTrackImage,disabledMinimumTrackImage,highlightedMinimumTrackImage,
defaultMaximumTrackImage,selectedMaximumTrackImage,disabledMaximumTrackImage,highlightedMaximumTrackImage;


- (void)setDefaultThumbImage:(UIImage *)image{
    [self setThumbImage:image forState:UIControlStateNormal];
}

- (UIImage*)defaultThumbImage{
    return [self thumbImageForState:UIControlStateNormal];
}

- (void)setSelectedThumbImage:(UIImage *)image{
    [self setThumbImage:image forState:UIControlStateSelected];
}

- (UIImage*)selectedThumbImage{
    return [self thumbImageForState:UIControlStateSelected];
}

- (void)setDisabledThumbImage:(UIImage *)image{
    [self setThumbImage:image forState:UIControlStateDisabled];
}

- (UIImage*)disabledThumbImage{
    return [self thumbImageForState:UIControlStateDisabled];
}

- (void)setHighlightedThumbImage:(UIImage *)image{
    [self setThumbImage:image forState:UIControlStateHighlighted];
}

- (UIImage*)highlightedThumbImage{
    return [self thumbImageForState:UIControlStateHighlighted];
}

- (void)setDefaultMinimumTrackImage:(UIImage *)image{
    [self setMinimumTrackImage:image forState:UIControlStateNormal];
}

- (UIImage*)defaultMinimumTrackImage{
    return [self minimumTrackImageForState:UIControlStateNormal];
}

- (void)setSelectedMinimumTrackImage:(UIImage *)image{
    [self setMinimumTrackImage:image forState:UIControlStateSelected];
}

- (UIImage*)selectedMinimumTrackImage{
    return [self minimumTrackImageForState:UIControlStateSelected];
}

- (void)setDisabledMinimumTrackImage:(UIImage *)image{
    [self setMinimumTrackImage:image forState:UIControlStateDisabled];
}

- (UIImage*)disabledMinimumTrackImage{
    return [self minimumTrackImageForState:UIControlStateDisabled];
}

- (void)setHighlightedMinimumTrackImage:(UIImage *)image{
    [self setMinimumTrackImage:image forState:UIControlStateHighlighted];
}

- (UIImage*)highlightedMinimumTrackImage{
    return [self minimumTrackImageForState:UIControlStateHighlighted];
}

- (void)setDefaultMaximumTrackImage:(UIImage *)image{
    [self setMaximumTrackImage:image forState:UIControlStateNormal];
}

- (UIImage*)defaultMaximumTrackImage{
    return [self maximumTrackImageForState:UIControlStateNormal];
}

- (void)setSelectedMaximumTrackImage:(UIImage *)image{
    [self setMaximumTrackImage:image forState:UIControlStateSelected];
}

- (UIImage*)selectedMaximumTrackImage{
    return [self maximumTrackImageForState:UIControlStateSelected];
}

- (void)setDisabledMaximumTrackImage:(UIImage *)image{
    [self setMaximumTrackImage:image forState:UIControlStateDisabled];
}

- (UIImage*)disabledMaximumTrackImage{
    return [self maximumTrackImageForState:UIControlStateDisabled];
}

- (void)setHighlightedMaximumTrackImage:(UIImage *)image{
    [self setMaximumTrackImage:image forState:UIControlStateHighlighted];
}

- (UIImage*)highlightedMaximumTrackImage{
    return [self maximumTrackImageForState:UIControlStateHighlighted];
}

@end

