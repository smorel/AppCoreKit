//
//  UILabel+Style.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKUIView+Style.h"

/** TODO
 */
extern NSString* CKStyleFontSize;

/** TODO
 */
extern NSString* CKStyleFontName;


/** TODO
 */
@interface NSMutableDictionary (CKUILabelStyle)
- (CGFloat)fontSize;
- (NSString*)fontName;
@end


/** TODO
 */
@interface UILabel (CKStyle)

@end


@interface UITextField (CKStyle)

@end