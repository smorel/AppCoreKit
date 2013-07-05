//
//  UILabel+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UILabel+CKLayout.h"
#import "UIView+CKLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKRuntime.h"
#import <objc/runtime.h>

@interface CKLayoutBox()

+ (CGSize)preferedSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end


static char UILabelFlexibleWidthKey;
static char UILabelFlexibleHeightKey;

@implementation UILabel (CKLayout)
@dynamic flexibleWidth,flexibleHeight,flexibleSize;

- (void)setFlexibleWidth:(BOOL)flexibleWidth{
    objc_setAssociatedObject(self,
                             &UILabelFlexibleWidthKey,
                             [NSNumber numberWithBool:flexibleWidth],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)flexibleWidth{
    id value = objc_getAssociatedObject(self, &UILabelFlexibleWidthKey);
    return value ? [value boolValue] : NO;
}

- (void)setFlexibleHeight:(BOOL)flexibleHeight{
    objc_setAssociatedObject(self,
                             &UILabelFlexibleHeightKey,
                             [NSNumber numberWithBool:flexibleHeight],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)flexibleHeight{
    id value = objc_getAssociatedObject(self, &UILabelFlexibleHeightKey);
    return value ? [value boolValue] : NO;
}

- (void)setFlexibleSize:(BOOL)flexibleSize{
    [self setFlexibleHeight:flexibleSize];
    [self setFlexibleWidth:flexibleSize];
}

- (BOOL)flexibleSize{
    return self.flexibleHeight && self.flexibleWidth;
}


- (CGSize)preferedSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGSize maxSize = CGSizeMake(size.width, (self.numberOfLines > 0) ? self.numberOfLines * self.font.lineHeight : MAXFLOAT);
    CGSize ret = [self.text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode:self.lineBreakMode];
    
    //Backward Compatibility
    if([self.containerLayoutBox isKindOfClass:[CKVerticalBoxLayout class]]){
        id value = objc_getAssociatedObject(self, &UILabelFlexibleWidthKey);
        if(!value){
            ret.width = size.width;
        }
    }
    
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

- (void)invalidateLayout{
    if([[self superview] isKindOfClass:[UIButton class]]){
        UIButton* bu = (UIButton*)[self superview];
        [bu invalidateLayout];
        return;
    }
    
    [super invalidateLayout];
}

- (void)UILabel_Layout_setText:(NSString*)text{
    if(![text isEqualToString:self.text]){
        [self UILabel_Layout_setText:text];
        [self invalidateLayout];
    }
}

- (void)UILabel_Layout_setFont:(UIFont*)font{
    if(![font isEqual:self.font]){
        [self UILabel_Layout_setFont:font];
        [self invalidateLayout];
    }
}

+ (void)load{
    CKSwizzleSelector([UILabel class], @selector(setText:), @selector(UILabel_Layout_setText:));
    CKSwizzleSelector([UILabel class], @selector(setFont:), @selector(UILabel_Layout_setFont:));
}

@end
