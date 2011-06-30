//
//  UILabel+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKUIView+Style.h"


/** TODO
 */
@interface UILabel (CKValueTransformer)
@end


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