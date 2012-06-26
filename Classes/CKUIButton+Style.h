//
//  CKUIButton+Style.h
//  CloudKit
//
//  Created by Olivier Collet on 11-04-29.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKUIView+Style.h"

/* SUPPORTS :
 * CKStyleDefaultBackgroundImage
 * CKStyleDefaultImage
 */


/**
 */
extern NSString *CKStyleDefaultBackgroundImage;

/**
 */
extern NSString *CKStyleDefaultImage;

/**
 */
extern NSString *CKStyleDefaultTextColor;


/**
 */
@interface NSMutableDictionary (CKUIButtonStyle)

- (UIImage *)defaultBackgroundImage;
- (UIImage *)defaultImage;
- (UIColor *)defaultTextColor;
- (NSString *)defaultTitle;

- (UIImage *)highlightedBackgroundImage;
- (UIImage *)highlightedImage;
- (UIColor *)highlightedTextColor;
- (NSString *)highlightedTitle;

- (UIImage *)selectedBackgroundImage;
- (UIImage *)selectedImage;
- (UIColor *)selectedTextColor;
- (NSString *)selectedTitle;

- (UIImage *)disabledBackgroundImage;
- (UIImage *)disabledImage;
- (UIColor *)disabledTextColor;
- (NSString *)disabledTitle;

@end


/**
 */
@interface UIButton (CKStyle)

@end
