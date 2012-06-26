//
//  UILabel+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKUIView+Style.h"

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