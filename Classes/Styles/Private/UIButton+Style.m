//
//  UIButton+Style.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UIButton+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "UILabel+Style.h"

//

@implementation UIButton (CKStyle)

@dynamic defaultBackgroundImage;
@dynamic defaultImage;
@dynamic defaultTextColor;
@dynamic defaultTextShadowColor;
@dynamic defaultTitle;

@dynamic highlightedBackgroundImage;
@dynamic highlightedImage;
@dynamic highlightedTextColor;
@dynamic highlightedTextShadowColor;
@dynamic highlightedTitle;

@dynamic selectedBackgroundImage;
@dynamic selectedImage;
@dynamic selectedTextColor;
@dynamic selectedTextShadowColor;
@dynamic selectedTitle;

@dynamic disabledBackgroundImage;
@dynamic disabledImage;
@dynamic disabledTextColor;
@dynamic disabledTextShadowColor;
@dynamic disabledTitle;

@dynamic font;
@dynamic fontName;
@dynamic fontSize;

- (void)_resize{
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    [self sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,MAX(width,self.frame.size.width),(height <= 0) ? MAX(height,self.frame.size.height) : height);
}


#define SETTERS(NAME,STATE) \
- (void)set##NAME##BackgroundImage:(UIImage *)image{\
    [self setBackgroundImage:image forState:STATE];\
}\
- (void)set##NAME##Image:(UIImage *)image{\
    [self setImage:image forState:STATE];\
    [self _resize];\
}\
- (void)set##NAME##TextColor:(UIColor *)color{\
    [self setTitleColor:color forState:STATE];\
}\
- (void)set##NAME##TextShadowColor:(UIColor *)color{\
    [self setTitleShadowColor:color forState:STATE];\
}\
- (void)set##NAME##Title:(NSString *)text{\
    [self setTitle:text forState:STATE];\
    [self _resize];\
}


SETTERS(Default,UIControlStateNormal);
SETTERS(Highlighted,UIControlStateHighlighted);
SETTERS(Selected,UIControlStateSelected);
SETTERS(Disabled,UIControlStateDisabled);



#define GETTERS(NAME,STATE) \
- (UIImage*)NAME##BackgroundImage{\
    return [self backgroundImageForState:STATE];\
}\
- (UIImage*)NAME##Image{\
    return [self imageForState:STATE];\
}\
- (UIColor*)NAME##TextColor{\
    return [self titleColorForState:STATE];\
}\
- (UIColor*)NAME##TextShadowColor{\
    return [self titleShadowColorForState:STATE];\
}\
- (NSString*)NAME##Title{\
    return [self titleForState:STATE];\
}


GETTERS(default,UIControlStateNormal);
GETTERS(highlighted,UIControlStateHighlighted);
GETTERS(selected,UIControlStateSelected);
GETTERS(disabled,UIControlStateDisabled);

- (void)setFont:(UIFont *)font{
    self.titleLabel.font = font;
    [self _resize];
}

- (UIFont*)font{
    return self.titleLabel.font;
}

- (void)setFontName:(NSString *)fontName{
    CGFloat fontSize = self.titleLabel.font.pointSize;
    [self setFont:[UIFont fontWithName:fontName size:fontSize]];
}

- (NSString*)fontName{
    return self.titleLabel.font.fontName;
}

- (void)setFontSize:(CGFloat)fontSize{
    NSString* fontName = self.titleLabel.font.fontName;
    [self setFont:[UIFont fontWithName:fontName size:fontSize]];
}

- (CGFloat)fontSize{
    return self.titleLabel.font.pointSize;
}

@end
