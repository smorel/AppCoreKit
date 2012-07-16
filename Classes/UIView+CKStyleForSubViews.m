//
//  UIView+CKStyleForSubViews.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "UIView+CKStyleForSubViews.h"
#import "CKRuntime.h"
#import "CKUIView+Style.h"
#import "CKStyleManager.h"

@implementation UIView (CKStyleForSubViews)

- (void)ckDidAddSubview:(UIView *)subview{
    if([subview appliedStyle] == nil && [self appliedStyle] != nil){
        [subview applyStyle:[self appliedStyle]];
    }
    [self ckDidAddSubview:subview];
}

+ (void)load{
    CKSwizzleSelector([UIView class], @selector(didAddSubview:), @selector(ckDidAddSubview:));
}

@end
