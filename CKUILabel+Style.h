//
//  UILabel+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Style.h"

extern NSString* CKStyleTextColor;
extern NSString* CKStyleFontSize;
extern NSString* CKStyleFontName;
extern NSString* CKStyleText;
extern NSString* CKStyleNumberOfLines;

@interface NSDictionary (CKUILabelStyle)

- (UIColor*)textColor;
- (CGFloat)fontSize;
- (NSString*)fontName;
- (NSString*)text;
- (NSInteger)numberOfLines;

@end

/* SUPPORTS :
     * CKStyleBackgroundStyle
     * CKStyleTextColor
     * CKStyleTextFontSize
     * CKStyleTextFontName
     * CKStyleText
 */
@interface UILabel (CKStyle)

+ (BOOL)applyStyle:(NSDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack;

@end
