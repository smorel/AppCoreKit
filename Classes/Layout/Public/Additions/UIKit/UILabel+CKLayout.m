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
#import "CKStringHelper.h"
#import "CKVersion.h"

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end


static char UILabelFlexibleWidthKey;
static char UILabelFlexibleHeightKey;
static char UILabelUsesAttributedStringKey;

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


- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize)){
        return self.lastPreferedSize;
    }
    
    /* Temporarily removes this optimization as it doesn't handle all the cases correctly.
    CGFloat numberOfLines = self.font.lineHeight > 0 ? self.bounds.size.height / self.font.lineHeight : 0;
    
    if(   (self.lastPreferedSize.width > 0 && self.lastPreferedSize.height > 0)
       && ((self.lastComputedSize.width == size.width && self.lastPreferedSize.height <= size.height)
           || (self.lastPreferedSize.width <= size.width && numberOfLines < 2) )){
        self.lastComputedSize = size;
        return self.lastPreferedSize;
    }*/
    
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGFloat theWidth = (self.maximumSize.width != MAXFLOAT) ? MIN(self.maximumSize.width,size.width) : size.width;
    theWidth = (self.minimumSize.width != -MAXFLOAT) ? MAX(self.minimumSize.width,theWidth) : theWidth;
    
    CGSize maxSize = CGSizeMake(theWidth, (self.numberOfLines > 0) ? self.numberOfLines * self.font.lineHeight : MAXFLOAT);
    
    CGSize ret = CGSizeZero;
    
    if(![self usesAttributedString] && self.text && [self.text length] > 0){
        ret = (self.font.lineHeight == 0) ? CGSizeMake(0,0) : [CKStringHelper sizeForText:self.text font:self.font constrainedToSize:maxSize lineBreakMode:self.lineBreakMode];
    }else if([CKOSVersion() floatValue] >= 6){
        if(self.attributedText){
            ret = [CKStringHelper sizeForAttributedText:self.attributedText constrainedToSize:maxSize];
        }
    }
    
    //Backward Compatibility : Flexible width when in vertical layout to be able to handle textAlignment property
    if([self.containerLayoutBox isKindOfClass:[CKVerticalBoxLayout class]]){
        id value = objc_getAssociatedObject(self, &UILabelFlexibleWidthKey);
        if(!value){
            //If vertical layout in scroll view, constraint is infinite
            if(size.width < MAXFLOAT){
                ret.width = size.width;
            }
        }
    }
    
    if(self.flexibleWidth){
        ret.width = size.width;
    }
    if(self.flexibleHeight){
        ret.height = size.height;
    }
    
    ret = [CKLayoutBox preferredSizeConstraintToSize:ret forBox:self];
    
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


- (void)setUsesAttributedString:(BOOL)bo{
    objc_setAssociatedObject(self,
                             &UILabelUsesAttributedStringKey,
                             [NSNumber numberWithBool:bo],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)usesAttributedString{
    id value = objc_getAssociatedObject(self, &UILabelUsesAttributedStringKey);
    return value ? [value boolValue] : NO;
}

- (void)UILabel_Layout_setText:(NSString*)text{
    if(![text isEqualToString:self.text]){
        [self setUsesAttributedString:NO];
        
        [self UILabel_Layout_setText:text];
        
        if(self.numberOfLines == 1 && !CGSizeEqualToSize(self.fixedSize, CGSizeMake(MAXFLOAT, MAXFLOAT)) )
            return;
        
        [self invalidateLayout];
    }
}

- (void)UILabel_Layout_setFont:(UIFont*)font{
    if(![font isEqual:self.font]){
        [self UILabel_Layout_setFont:font];
        
        if(self.numberOfLines == 1 && !CGSizeEqualToSize(self.fixedSize, CGSizeMake(MAXFLOAT, MAXFLOAT)) )
            return;
        
        [self invalidateLayout];
    }
}
- (void)UILabel_Layout_setAttributedText:(NSAttributedString*)attributedText{
    if(![attributedText isEqualToAttributedString:self.attributedText]){
        [self setUsesAttributedString:YES];
        
        [self UILabel_Layout_setAttributedText:attributedText];
        
        if(self.numberOfLines == 1 && !CGSizeEqualToSize(self.fixedSize, CGSizeMake(MAXFLOAT, MAXFLOAT)) )
            return;
        
        [self invalidateLayout];
    }
}

+ (void)load{
    CKSwizzleSelector([UILabel class], @selector(setText:), @selector(UILabel_Layout_setText:));
    if([CKOSVersion() floatValue] >= 6){
        CKSwizzleSelector([UILabel class], @selector(setAttributedText:), @selector(UILabel_Layout_setAttributedText:));
    }
    CKSwizzleSelector([UILabel class], @selector(setFont:), @selector(UILabel_Layout_setFont:));
}

@end
