//
//  UIButton+Style.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Style.h"

/**
 */
@interface UIButton (CKStyle)

/**
 */
@property (nonatomic) UIImage *defaultBackgroundImage;
/**
 */
@property (nonatomic) UIImage *defaultImage;
/**
 */
@property (nonatomic) UIColor *defaultTextColor;
/**
 */
@property (nonatomic) UIColor *defaultTextShadowColor;
/**
 */
@property (nonatomic) NSString *defaultTitle;

@property (nonatomic) UIImage *highlightedBackgroundImage;
/**
 */
@property (nonatomic) UIImage *highlightedImage;
/**
 */
@property (nonatomic) UIColor *highlightedTextColor;
/**
 */
@property (nonatomic) UIColor *highlightedTextShadowColor;
/**
 */
@property (nonatomic) NSString *highlightedTitle;

/**
 */
@property (nonatomic) UIImage *selectedBackgroundImage;
/**
 */
@property (nonatomic) UIImage *selectedImage;
/**
 */
@property (nonatomic) UIColor *selectedTextColor;
/**
 */
@property (nonatomic) UIColor *selectedTextShadowColor;
/**
 */
@property (nonatomic) NSString *selectedTitle;

/**
 */
@property (nonatomic) UIImage *disabledBackgroundImage;
/**
 */
@property (nonatomic) UIImage *disabledImage;
/**
 */
@property (nonatomic) UIColor *disabledTextColor;
/**
 */
@property (nonatomic) UIColor *disabledTextShadowColor;
/**
 */
@property (nonatomic) NSString *disabledTitle;

/**
 */
@property (nonatomic) UIFont *font;
/**
 */
@property (nonatomic) NSString *fontName;
/**
 */
@property (nonatomic) CGFloat fontSize;

@end
