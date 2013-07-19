//
//  UIViewController+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UIViewController+CKLayout.h"
#import "UIView+CKLayout.h"
#import "CKRuntime.h"

@interface CKLayoutBox()

+ (CGSize)preferedSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@implementation UIViewController(CKLayout)

- (UIView*)UIViewController_Layout_view{
    UIView* v = [self UIViewController_Layout_view];
    if(v){
        v.sizeToFitLayoutBoxes = NO;
    }
    return v;
}

+ (void)load{
    CKSwizzleSelector([UIViewController class], @selector(view), @selector(UIViewController_Layout_view));
}

@end