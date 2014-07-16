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

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@implementation UIViewController(CKLayout)

- (void)UIViewController_Layout_loadView{
    [self UIViewController_Layout_loadView];
    if(self.view){
        self.view.sizeToFitLayoutBoxes = NO;
    }
}

+ (void)load{
    CKSwizzleSelector([UIViewController class], @selector(loadView), @selector(UIViewController_Layout_loadView));
}

@end