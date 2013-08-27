//
//  UILabel+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Style.h"

/**
 */
extern NSString* CKStyleFontSize;

/**
 */
extern NSString* CKStyleFontName;


/**
 */
@interface NSMutableDictionary (CKUILabelStyle)
- (CGFloat)fontSize;
- (NSString*)fontName;
@end


/**
 */
@interface UILabel (CKStyle)

@end


@interface UITextField (CKStyle)

@end