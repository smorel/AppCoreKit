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


NSString *CKStyleDefaultBackgroundImage = @"defaultBackgroundImage";
NSString *CKStyleDefaultImage = @"defaultImage";
NSString *CKStyleDefaultTextColor = @"defaultTextColor";
NSString *CKStyleDefaultShadowColor = @"defaultShadowColor";
NSString *CKStyleDefaultTitle = @"defaultTitle";

NSString *CKStyleHighlightedBackgroundImage = @"highlightedBackgroundImage";
NSString *CKStyleHighlightedImage = @"highlightedImage";
NSString *CKStyleHighlightedTextColor = @"highlightedTextColor";
NSString *CKStyleHighlightedShadowColor = @"highlightedShadowColor";
NSString *CKStyleHighlightedTitle = @"highlightedTitle";

NSString *CKStyleDisabledBackgroundImage = @"disabledBackgroundImage";
NSString *CKStyleDisabledImage = @"disabledImage";
NSString *CKStyleDisabledTextColor = @"disabledTextColor";
NSString *CKStyleDisabledShadowColor = @"disabledShadowColor";
NSString *CKStyleDisabledTitle = @"disabledTitle";

NSString *CKStyleSelectedBackgroundImage = @"selectedBackgroundImage";
NSString *CKStyleSelectedImage = @"selectedImage";
NSString *CKStyleSelectedTextColor = @"selectedTextColor";
NSString *CKStyleSelectedShadowColor = @"selectedShadowColor";
NSString *CKStyleSelectedTitle = @"selectedTitle";

@implementation NSMutableDictionary (CKUIButtonStyle)

- (UIImage*)defaultBackgroundImage {
	return [self imageForKey:CKStyleDefaultBackgroundImage];
}

- (UIImage*)defaultImage {
	return [self imageForKey:CKStyleDefaultImage];
}

- (UIColor *)defaultTextColor {
	return [self colorForKey:CKStyleDefaultTextColor];
}

- (NSString *)defaultTitle {
	return [self stringForKey:CKStyleDefaultTitle];
}

- (UIColor *)defaultShadowColor {
	return [self colorForKey:CKStyleDefaultShadowColor];
}

- (UIImage*)highlightedBackgroundImage {
	return [self imageForKey:CKStyleHighlightedBackgroundImage];
}

- (UIImage*)highlightedImage {
	return [self imageForKey:CKStyleHighlightedImage];
}

- (UIColor *)highlightedTextColor {
	return [self colorForKey:CKStyleHighlightedTextColor];
}

- (NSString *)highlightedTitle {
	return [self stringForKey:CKStyleHighlightedTitle];
}

- (UIColor *)highlightedShadowColor {
	return [self colorForKey:CKStyleHighlightedShadowColor];
}

- (UIImage*)disabledBackgroundImage {
	return [self imageForKey:CKStyleDisabledBackgroundImage];
}

- (UIImage*)disabledImage {
	return [self imageForKey:CKStyleDisabledImage];
}

- (UIColor *)disabledTextColor {
	return [self colorForKey:CKStyleDisabledTextColor];
}

- (NSString *)disabledTitle {
	return [self stringForKey:CKStyleDisabledTitle];
}

- (UIColor *)disabledShadowColor {
	return [self colorForKey:CKStyleDisabledShadowColor];
}

- (UIImage*)selectedBackgroundImage {
	return [self imageForKey:CKStyleSelectedBackgroundImage];
}

- (UIImage*)selectedImage {
	return [self imageForKey:CKStyleSelectedImage];
}

- (UIColor *)selectedTextColor {
	return [self colorForKey:CKStyleSelectedTextColor];
}

- (NSString *)selectedTitle {
	return [self stringForKey:CKStyleSelectedTitle];
}

- (UIColor *)selectedShadowColor {
	return [self colorForKey:CKStyleSelectedShadowColor];
}

@end

//

@implementation UIButton (CKStyle)

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords{
    [super updateReservedKeyWords:keyWords];
	[keyWords addObjectsFromArray:[NSArray arrayWithObjects:CKStyleDefaultBackgroundImage,CKStyleDefaultImage,CKStyleDefaultTextColor,CKStyleDefaultTitle,CKStyleDefaultShadowColor,
                                   CKStyleHighlightedBackgroundImage,CKStyleHighlightedImage,CKStyleHighlightedTextColor,CKStyleHighlightedTitle,CKStyleHighlightedShadowColor,
                                   CKStyleDisabledBackgroundImage,CKStyleDisabledImage,CKStyleDisabledTextColor,CKStyleDisabledTitle,CKStyleDisabledShadowColor,
                                   CKStyleSelectedBackgroundImage,CKStyleSelectedImage,CKStyleSelectedTextColor,CKStyleSelectedTitle,CKStyleSelectedShadowColor,
                                   nil]];
}

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
		UIButton* button = (UIButton *)view;
		NSMutableDictionary* myButtonStyle = style;
		if(myButtonStyle && ![myButtonStyle isEmpty]){
            //default state
			if ([myButtonStyle containsObjectForKey:CKStyleDefaultBackgroundImage]) {
                [button setBackgroundImage:[myButtonStyle defaultBackgroundImage] forState:UIControlStateNormal];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleDefaultImage]){
                [button setImage:[myButtonStyle defaultImage] forState:UIControlStateNormal];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleDefaultTextColor]) {
                [button setTitleColor:[myButtonStyle defaultTextColor] forState:UIControlStateNormal];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleDefaultTitle]) {
                [button setTitle:[myButtonStyle defaultTitle] forState:UIControlStateNormal];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleDefaultShadowColor]) {
                [button setTitleShadowColor:[myButtonStyle defaultShadowColor] forState:UIControlStateNormal];
            }
            
            //highlighted state
			if ([myButtonStyle containsObjectForKey:CKStyleHighlightedBackgroundImage]) {
                [button setBackgroundImage:[myButtonStyle highlightedBackgroundImage] forState:UIControlStateHighlighted];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleHighlightedImage]){
                [button setImage:[myButtonStyle highlightedImage] forState:UIControlStateHighlighted];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleHighlightedTextColor]) {
                [button setTitleColor:[myButtonStyle highlightedTextColor] forState:UIControlStateHighlighted];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleHighlightedTitle]) {
                [button setTitle:[myButtonStyle highlightedTitle] forState:UIControlStateHighlighted];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleHighlightedShadowColor]) {
                [button setTitleShadowColor:[myButtonStyle highlightedShadowColor] forState:UIControlStateHighlighted];
            }
            
            //disabled state
			if ([myButtonStyle containsObjectForKey:CKStyleDisabledBackgroundImage]) {
                [button setBackgroundImage:[myButtonStyle disabledBackgroundImage] forState:UIControlStateDisabled];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleDisabledImage]){
                [button setImage:[myButtonStyle disabledImage] forState:UIControlStateDisabled];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleDisabledTextColor]) {
                [button setTitleColor:[myButtonStyle disabledTextColor] forState:UIControlStateDisabled];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleDisabledTitle]) {
                [button setTitle:[myButtonStyle disabledTitle] forState:UIControlStateDisabled];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleDisabledShadowColor]) {
                [button setTitleShadowColor:[myButtonStyle disabledShadowColor] forState:UIControlStateDisabled];
            }
            
            //selected state
			if ([myButtonStyle containsObjectForKey:CKStyleSelectedBackgroundImage]) {
                [button setBackgroundImage:[myButtonStyle selectedBackgroundImage] forState:UIControlStateSelected];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleSelectedImage]){
                [button setImage:[myButtonStyle selectedImage] forState:UIControlStateSelected];
            }
			if ([myButtonStyle containsObjectForKey:CKStyleSelectedTextColor]) {
                [button setTitleColor:[myButtonStyle selectedTextColor] forState:UIControlStateSelected];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleSelectedTitle]) {
                [button setTitle:[myButtonStyle selectedTitle] forState:UIControlStateSelected];
            }
            if ([myButtonStyle containsObjectForKey:CKStyleSelectedShadowColor]) {
                [button setTitleShadowColor:[myButtonStyle selectedShadowColor] forState:UIControlStateSelected];
            }
            
            //Font
            NSString* fontName = button.titleLabel.font.fontName;
			if([myButtonStyle containsObjectForKey:CKStyleFontName])
				fontName= [myButtonStyle fontName];
			CGFloat fontSize = button.titleLabel.font.pointSize;
			if([myButtonStyle containsObjectForKey:CKStyleFontSize])
				fontSize= [myButtonStyle fontSize];
			button.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
            
            CGFloat height = button.bounds.size.height;
            CGFloat width = button.bounds.size.width;
            [button sizeToFit];
            button.frame = CGRectMake(button.frame.origin.x,button.frame.origin.y,MAX(width,button.frame.size.width),(height <= 0) ? MAX(height,button.frame.size.height) : height);
            
			return YES;
		}
		return YES;
	}
	return NO;
}

@end
