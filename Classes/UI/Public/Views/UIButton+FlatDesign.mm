//
//  UIButton+FlatDesign.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-30.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "UIButton+FlatDesign.h"
#import <objc/runtime.h>
#import "CKRuntime.h"


static char UIButtonDefaultFontKey;
static char UIButtonHighlightedFontKey;
static char UIButtonDisabledFontKey;
static char UIButtonSelectedFontKey;

@implementation UIButton (Fonts)
@dynamic defaultFont,highlightedFont,disabledFont,selectedFont;

- (void)setDefaultFont:(UIFont*)font{
    objc_setAssociatedObject(self,
                             &UIButtonDefaultFontKey,
                             font,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateFont];
}

- (UIColor*)defaultFont{
    return objc_getAssociatedObject(self, &UIButtonDefaultFontKey);
}

- (void)setHighlightedFont:(UIFont*)font{
    objc_setAssociatedObject(self,
                             &UIButtonHighlightedFontKey,
                             font,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateFont];
}

- (UIColor*)highlightedFont{
    return objc_getAssociatedObject(self, &UIButtonHighlightedFontKey);
}

- (void)setDisabledFont:(UIFont*)font{
    objc_setAssociatedObject(self,
                             &UIButtonDisabledFontKey,
                             font,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateFont];
    
}

- (UIColor*)disabledFont{
    return objc_getAssociatedObject(self, &UIButtonDisabledFontKey);
}

- (void)setSelectedFont:(UIFont*)font{
    objc_setAssociatedObject(self,
                             &UIButtonSelectedFontKey,
                             font,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateFont];
    
}

- (UIColor*)selectedFont{
    return objc_getAssociatedObject(self, &UIButtonSelectedFontKey);
}

- (void)setFont:(UIFont *)font forState:(UIControlState)state{
    switch(state){
        case UIControlStateNormal:      [self setDefaultFont:font];     break;
        case UIControlStateHighlighted: [self setHighlightedFont:font]; break;
        case UIControlStateDisabled:    [self setDisabledFont:font];    break;
        case UIControlStateSelected:    [self setSelectedFont:font];    break;
        case UIControlStateApplication:
        case UIControlStateReserved:
            break;
    }
}

- (UIFont *)fontForState:(UIControlState)state{
    UIFont* font = [self defaultFont];
    switch(state){
        case UIControlStateNormal:      font = [self defaultFont];     break;
        case UIControlStateHighlighted: font = [self highlightedFont]; break;
        case UIControlStateDisabled:    font = [self disabledFont];    break;
        case UIControlStateSelected:    font = [self selectedFont];    break;
        case UIControlStateApplication:
        case UIControlStateReserved:
            break;
    }
    
    return font;
}

- (void)updateFont{
    UIFont* font = nil;
    if(self.highlighted){
        font = [self fontForState:UIControlStateHighlighted];
    }else if(!self.enabled){
        font = [self fontForState:UIControlStateDisabled];
    }else if(self.selected){
        font = [self fontForState:UIControlStateSelected];
    }
    
    if(!font){
        font = [self fontForState:UIControlStateNormal];
    }
    
    if(font){
        self.titleLabel.font = font;
    }
}

@end





static char UIButtonDefaultBackgroundColorKey;
static char UIButtonHighlightedBackgroundColorKey;
static char UIButtonDisabledBackgroundColorKey;
static char UIButtonSelectedBackgroundColorKey;

@implementation UIButton (FlatDesign)
@dynamic defaultBackgroundColor,highlightedBackgroundColor,disabledBackgroundColor,selectedBackgroundColor;

- (void)setDefaultBackgroundColor:(UIColor *)color{
    objc_setAssociatedObject(self,
                             &UIButtonDefaultBackgroundColorKey,
                             color,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBackgroundColor];
}

- (UIColor*)defaultBackgroundColor{
    return objc_getAssociatedObject(self, &UIButtonDefaultBackgroundColorKey);
}

- (void)setHighlightedBackgroundColor:(UIColor *)color{
    objc_setAssociatedObject(self,
                             &UIButtonHighlightedBackgroundColorKey,
                             color,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBackgroundColor];
}

- (UIColor*)highlightedBackgroundColor{
    return objc_getAssociatedObject(self, &UIButtonHighlightedBackgroundColorKey);
}

- (void)setDisabledBackgroundColor:(UIColor *)color{
    objc_setAssociatedObject(self,
                             &UIButtonDisabledBackgroundColorKey,
                             color,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBackgroundColor];
    
}

- (UIColor*)disabledBackgroundColor{
    return objc_getAssociatedObject(self, &UIButtonDisabledBackgroundColorKey);
}

- (void)setSelectedBackgroundColor:(UIColor *)color{
    objc_setAssociatedObject(self,
                             &UIButtonSelectedBackgroundColorKey,
                             color,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBackgroundColor];
    
}

- (UIColor*)selectedBackgroundColor{
    return objc_getAssociatedObject(self, &UIButtonSelectedBackgroundColorKey);
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state{
    switch(state){
        case UIControlStateNormal:      [self setDefaultBackgroundColor:color];     break;
        case UIControlStateHighlighted: [self setHighlightedBackgroundColor:color]; break;
        case UIControlStateDisabled:    [self setDisabledBackgroundColor:color];    break;
        case UIControlStateSelected:    [self setSelectedBackgroundColor:color];    break;
        case UIControlStateApplication:
        case UIControlStateReserved:
            break;
    }
}

- (UIColor *)backgroundColorForState:(UIControlState)state{
    UIColor* color = [self defaultBackgroundColor];
    switch(state){
        case UIControlStateNormal:      color = [self defaultBackgroundColor];     break;
        case UIControlStateHighlighted: color = [self highlightedBackgroundColor]; break;
        case UIControlStateDisabled:    color = [self disabledBackgroundColor];    break;
        case UIControlStateSelected:    color = [self selectedBackgroundColor];    break;
        case UIControlStateApplication:
        case UIControlStateReserved:
            break;
    }
    
    return color;
}

- (void)updateBackgroundColor{
    UIColor* color = nil;
    if(self.highlighted){
        color = [self backgroundColorForState:UIControlStateHighlighted];
    }else if(!self.enabled){
        color = [self backgroundColorForState:UIControlStateDisabled];
    }else if(self.selected){
        color = [self backgroundColorForState:UIControlStateSelected];
    }
    
    if(!color){
        color = [self backgroundColorForState:UIControlStateNormal];
    }
    
    if(color){
        self.backgroundColor = color;
    }
}

- (void)UIButton_FlatDesign_setSelected:(BOOL)selected{
    [self UIButton_FlatDesign_setSelected:selected];
    [self updateBackgroundColor];
    [self updateFont];
}

- (void)UIButton_FlatDesign_setHighlighted:(BOOL)selected{
    [self UIButton_FlatDesign_setHighlighted:selected];
    [self updateBackgroundColor];
    [self updateFont];
}

- (void)UIButton_FlatDesign_setEnabled:(BOOL)selected{
    [self UIButton_FlatDesign_setEnabled:selected];
    [self updateBackgroundColor];
    [self updateFont];
}

@end


bool swizzle_button_flat_design(){
    
    CKSwizzleSelector([UIButton class],@selector(setSelected:),@selector(UIButton_FlatDesign_setSelected:));
    CKSwizzleSelector([UIButton class],@selector(setHighlighted:),@selector(UIButton_FlatDesign_setHighlighted:));
    CKSwizzleSelector([UIButton class],@selector(setEnabled:),@selector(UIButton_FlatDesign_setEnabled:));
    
    return true;
}

static bool kSwizzle_button_flat_design = swizzle_button_flat_design();





