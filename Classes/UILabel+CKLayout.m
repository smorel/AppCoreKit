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

@interface CKLayoutBox()

+ (CGSize)preferedSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@implementation UILabel (CKLayout)

- (CGSize)preferedSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGSize maxSize = CGSizeMake(size.width, (self.numberOfLines > 0) ? self.numberOfLines * self.font.lineHeight : MAXFLOAT);
    CGSize ret = [self.text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode:self.lineBreakMode];
    
    if([self.containerLayoutBox isKindOfClass:[CKVerticalBoxLayout class]])
        ret.width = size.width;
    
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
