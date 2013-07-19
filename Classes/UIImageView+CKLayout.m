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

@interface CKLayoutBox()

+ (CGSize)preferedSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@implementation UIImageView (CKLayout)

- (void)invalidateLayout{
    if([[self superview] isKindOfClass:[UIButton class]]){
        UIButton* bu = (UIButton*)[self superview];
        [bu invalidateLayout];
        return;
    }
    
    //Do not invalidate layout here as image view size do not depend on image ...
    //[super invalidateLayout];
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