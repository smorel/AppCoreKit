//
//  UITextField+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UITextField+CKLayout.h"
#import "UIView+CKLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKRuntime.h"

@interface CKLayoutBox()

+ (CGSize)preferedSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end


@implementation UITextField (CKLayout)

- (CGSize)preferedSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGSize maxSize = CGSizeMake(size.width, MAXFLOAT);
    CGSize ret = [self.text sizeWithFont:self.font constrainedToSize:maxSize];
    
    if([self.containerLayoutBox isKindOfClass:[CKVerticalBoxLayout class]])
        ret.width = size.width;
    
    ret = [CKLayoutBox preferedSizeConstraintToSize:ret forBox:self];
    
    if(ret.height < self.font.lineHeight){
        ret.height = self.font.lineHeight;
    }
    
    //Adds padding 8
    
    CGFloat width = MAX(size.width,ret.width) + self.padding.left + self.padding.right;
    CGFloat height = ret.height + self.padding.top + self.padding.bottom;
    self.lastPreferedSize = CGSizeMake(width,height);
    return self.lastPreferedSize;
}

- (void)UITextField_Layout_setText:(NSString*)text{
    if(![text isEqualToString:self.text]){
        [self UITextField_Layout_setText:text];
        [self invalidateLayout];
    }
}

- (void)UITextField_Layout_setFont:(UIFont*)font{
    if(![font isEqual:self.font]){
        [self UITextField_Layout_setFont:font];
        [self invalidateLayout];
    }
}

+ (void)load{
    CKSwizzleSelector([UITextField class], @selector(setText:), @selector(UITextField_Layout_setText:));
    CKSwizzleSelector([UITextField class], @selector(setFont:), @selector(UITextField_Layout_setFont:));
}

@end
