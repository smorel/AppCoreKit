//
//  UILabel+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Style.h"

extern NSString* CKStyleTextColor;
extern NSString* CKStyleHighlightedTextColor;
extern NSString* CKStyleFontSize;
extern NSString* CKStyleFontName;
extern NSString* CKStyleText;
extern NSString* CKStyleNumberOfLines;
extern NSString* CKStyleShadowColor;
extern NSString* CKStyleShadowOffset;

@interface NSMutableDictionary (CKUILabelStyle)

- (UIColor*)textColor;
- (UIColor*)highlightedTextColor;
- (CGFloat)fontSize;
- (NSString*)fontName;
- (NSString*)text;
- (NSInteger)numberOfLines;
- (UIColor *)shadowColor;
- (CGSize)shadowOffset;

@end

/* SUPPORTS :
     * CKStyleBackgroundStyle
     * CKStyleTextColor
     * CKStyleTextFontSize
     * CKStyleTextFontName
     * CKStyleText
 */
@interface UILabel (CKStyle)

@end
