//
//  UIPickerView+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 1/29/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import "UIPickerView+CKLayout.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "CKPropertyExtendedAttributes.h"
#import "CKStyleManager.h"
#import "CKRuntime.h"
#import "UIView+Name.h"
#import "CKStyleView.h"

#import "UIView+CKLayout.h"
#import "CKRuntime.h"


@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@implementation UIPickerView (CKLayout)

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGSize ret = [self sizeThatFits:size];
    ret.height = MAX(162.0f, ret.height);

    ret = [CKLayoutBox preferredSizeConstraintToSize:ret forBox:self];
    
    self.lastPreferedSize = CGSizeMake(MIN(size.width,ret.width) + self.padding.left + self.padding.right,MIN(size.height,ret.height) + self.padding.top + self.padding.bottom);
    return self.lastPreferedSize;
}

@end
