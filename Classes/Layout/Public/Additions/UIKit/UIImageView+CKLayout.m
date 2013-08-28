//
//  UIImageView+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UIImageView+CKLayout.h"
#import "UIView+CKLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKRuntime.h"
#import <objc/runtime.h>

CGSize CKSizeThatFitsRatio(CGSize size, CGFloat ratio){
    NSInteger ratioHeight = (size.width / ratio);
    NSInteger ratioWidth = (size.height * ratio);
    
    if(ratioHeight - size.height < 0){
        //
        NSInteger width = size.width;
        NSInteger height = ratioHeight;
        size = CGSizeMake( width, height);
    }else{
        NSInteger width = ratioWidth;
        NSInteger height = size.height;
        size = CGSizeMake( width, height);
    }
    
    return size;
}

@interface CKLayoutBox()

+ (CGSize)preferedSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

static char UIImageViewFlexibleWidthKey;
static char UIImageViewFlexibleHeightKey;

@implementation UIImageView (CKLayout)
@dynamic flexibleWidth,flexibleHeight,flexibleSize;

- (void)setFlexibleWidth:(BOOL)flexibleWidth{
    objc_setAssociatedObject(self,
                             &UIImageViewFlexibleWidthKey,
                             [NSNumber numberWithBool:flexibleWidth],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)flexibleWidth{
    id value = objc_getAssociatedObject(self, &UIImageViewFlexibleWidthKey);
    return value ? [value boolValue] : NO;
}

- (void)setFlexibleHeight:(BOOL)flexibleHeight{
    objc_setAssociatedObject(self,
                             &UIImageViewFlexibleHeightKey,
                             [NSNumber numberWithBool:flexibleHeight],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)flexibleHeight{
    id value = objc_getAssociatedObject(self, &UIImageViewFlexibleHeightKey);
    return value ? [value boolValue] : NO;
}

- (void)setFlexibleSize:(BOOL)flexibleSize{
    [self setFlexibleHeight:flexibleSize];
    [self setFlexibleWidth:flexibleSize];
}

- (BOOL)flexibleSize{
    return self.flexibleHeight && self.flexibleWidth;
}

- (void)invalidateLayout{
    if([[self superview] isKindOfClass:[UIButton class]]){
        UIButton* bu = (UIButton*)[self superview];
        [bu invalidateLayout];
        return;
    }
    
    [super invalidateLayout];
}

- (CGSize)preferedSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGSize ret = self.image ? self.image.size : CGSizeMake(0,0);
    
    //re-Compute after constraints to keep aspect ratio
    CGFloat aspect = (ret.height != 0) ? ((CGFloat)ret.width / (CGFloat)ret.height) : 1.0f;
    
    if(ret.width > size.width){
        ret.width = size.width;
    }
    if(ret.height > size.height){
        ret.height = size.height;
    }
    ret = CKSizeThatFitsRatio(ret,aspect);
    //---------------------
    
    if(self.flexibleWidth){
        ret.width = size.width;
    }
    
    if(self.flexibleHeight){
        ret.height = size.height;
    }
    
    ret = [CKLayoutBox preferedSizeConstraintToSize:ret forBox:self];
    
    
    self.lastPreferedSize = CGSizeMake(MIN(size.width,ret.width) + self.padding.left + self.padding.right,MIN(size.height,ret.height) + self.padding.top + self.padding.bottom);
    return self.lastPreferedSize;
}

- (void)UIImageView_Layout_setImage:(UIImage*)image{
    if(![image isEqual:self.image]){
        [self UIImageView_Layout_setImage:image];
        [self invalidateLayout];
    }
}

+ (void)load{
    CKSwizzleSelector([UIImageView class], @selector(setImage:), @selector(UIImageView_Layout_setImage:));
}

@end