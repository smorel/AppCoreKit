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
#import <objc/runtime.h>
#import "CKStringHelper.h"
#import "CKVersion.h"

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

static char UITextFieldUsesAttributedStringKey;

@implementation UITextField (CKLayout)

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    
  /*  if(   self.lastPreferedSize.width > 0
       && self.lastPreferedSize.height > 0
       && size.width >= self.lastComputedSize.width
       && size.height >= self.lastComputedSize.height
       && self.lastPreferedSize.width <= self.lastComputedSize.width
       && self.lastPreferedSize.height <= self.lastComputedSize.height){
        return self.lastPreferedSize;
    }*/
    
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGFloat theWidth = (self.maximumSize.width != MAXFLOAT) ? MIN(self.maximumSize.width,size.width) : size.width;
    theWidth = (self.minimumSize.width != -MAXFLOAT) ? MAX(self.minimumSize.width,theWidth) : theWidth;
    
    CGSize maxSize = CGSizeMake(theWidth, MAXFLOAT);
    
    CGSize ret = CGSizeZero;
    if(![self usesAttributedString] && self.text){
        ret = [CKStringHelper sizeForText:self.text font:self.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    }else if([CKOSVersion() floatValue] >= 6){
        if(self.attributedText){
            ret = [CKStringHelper sizeForAttributedText:self.attributedText constrainedToSize:maxSize];
        }
    }
    
    if([self.containerLayoutBox isKindOfClass:[CKVerticalBoxLayout class]])
        ret.width = size.width;
    
    ret = [CKLayoutBox preferredSizeConstraintToSize:ret forBox:self];
    
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
        [self setUsesAttributedString:NO];
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
- (void)UITextField_Layout_setAttributedText:(NSAttributedString*)attributedText{
    if(![attributedText isEqualToAttributedString:self.attributedText]){
        [self setUsesAttributedString:YES];
        
        [self UITextField_Layout_setAttributedText:attributedText];
        
        [self invalidateLayout];
    }
}
- (void)setUsesAttributedString:(BOOL)bo{
    objc_setAssociatedObject(self,
                             &UITextFieldUsesAttributedStringKey,
                             [NSNumber numberWithBool:bo],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)usesAttributedString{
    id value = objc_getAssociatedObject(self, &UITextFieldUsesAttributedStringKey);
    return value ? [value boolValue] : NO;
}

+ (void)load{
    CKSwizzleSelector([UITextField class], @selector(setText:), @selector(UITextField_Layout_setText:));
    if([CKOSVersion() floatValue] >= 6){
        CKSwizzleSelector([UITextField class], @selector(setAttributedText:), @selector(UITextField_Layout_setAttributedText:));
    }
    CKSwizzleSelector([UITextField class], @selector(setFont:), @selector(UITextField_Layout_setFont:));
}

@end
