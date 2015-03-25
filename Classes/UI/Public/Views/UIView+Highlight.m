//
//  UIView+Highlight.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIView+Highlight.h"
#import <objc/runtime.h>
#import "CKRuntime.h"

@implementation UIView (Highlight)
@dynamic highlightedBackgroundColor,highlighted;

static char UIViewHighlightedBackgroundColorKey;

- (void)setHighlightedBackgroundColor:(UIColor *)color{
    objc_setAssociatedObject(self,
                             &UIViewHighlightedBackgroundColorKey,
                             color,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBackgroundColor];
}

- (UIColor*)highlightedBackgroundColor{
    return objc_getAssociatedObject(self, &UIViewHighlightedBackgroundColorKey);
}

static char UIViewOriginalBackgroundColorKey;

- (void)setOriginalBackgroundColor:(UIColor *)color{
    objc_setAssociatedObject(self,
                             &UIViewOriginalBackgroundColorKey,
                             color,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor*)originalBackgroundColor{
    return objc_getAssociatedObject(self, &UIViewOriginalBackgroundColorKey);
}

static char UIViewHighlightedKey;

- (void)setHighlighted:(BOOL)highlighted{
    objc_setAssociatedObject(self,
                             &UIViewHighlightedKey,
                             @(highlighted),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBackgroundColor];
}

- (BOOL)isHighlighted{
    id value = objc_getAssociatedObject(self, &UIViewHighlightedKey);
    return value ? [value boolValue] : NO;
}

- (void)updateBackgroundColor{
    UIColor* color = nil;
    if([self isHighlighted]){
        [self setOriginalBackgroundColor:self.backgroundColor];
        color = [self highlightedBackgroundColor] ? [self highlightedBackgroundColor] : [self originalBackgroundColor];
    }else{
        color = [self originalBackgroundColor];
    }

    self.backgroundColor = color;
}

@end
