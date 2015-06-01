//
//  UIActivityIndicatorView+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-06-01.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIActivityIndicatorView+CKLayout.h"
#import "UIView+CKLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKRuntime.h"
#import <objc/runtime.h>
#import "CKStringHelper.h"

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end


@implementation UIActivityIndicatorView (CKLayout)

+ (void)load{
    CKSwizzleSelector([UIActivityIndicatorView class], @selector(setActivityIndicatorViewStyle:), @selector(AppCoreKit_setActivityIndicatorViewStyle:));
    CKSwizzleSelector([UIActivityIndicatorView class], @selector(initWithActivityIndicatorStyle:), @selector(AppCoreKit_initWithActivityIndicatorStyle:));
}

static char UIActivityIndicatorViewDefaultSizeKey;

- (void)_setDefaultSize:(CGSize)size{
    objc_setAssociatedObject(self, &UIActivityIndicatorViewDefaultSizeKey, [NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN);
}

- (CGSize)_defaultSize{
    id value = objc_getAssociatedObject(self, &UIActivityIndicatorViewDefaultSizeKey);
    return value ? [value CGSizeValue] : CGSizeZero;
}

- (instancetype)AppCoreKit_initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style{
    self = [self AppCoreKit_initWithActivityIndicatorStyle:style];
    CGSize size = self.bounds.size;
    [self _setDefaultSize:size];
    return self;
}

- (void)AppCoreKit_setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)style{
    [self AppCoreKit_setActivityIndicatorViewStyle:style];
    CGSize size = self.bounds.size;
    [self _setDefaultSize:size];
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGSize ret = self.flexibleSize ? size : [self _defaultSize];
    
    ret = [CKLayoutBox preferredSizeConstraintToSize:ret forBox:self];
    
    self.lastPreferedSize = CGSizeMake(MIN(size.width,ret.width) + self.padding.left + self.padding.right,MIN(size.height,ret.height) + self.padding.top + self.padding.bottom);
    return self.lastPreferedSize;
}

@end
