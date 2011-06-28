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


/** TODO
 */
extern NSString *CKStyleDefaultBackgroundImage;

/** TODO
 */
extern NSString *CKStyleDefaultImage;

/** TODO
 */
extern NSString *CKStyleDefaultTextColor;


/** TODO
 */
@interface NSMutableDictionary (CKUIButtonStyle)

- (UIImage *)defaultBackgroundImage;
- (UIImage *)defaultImage;
- (UIColor *)defaultTextColor;

@end


/** TODO
 */
@interface UIButton (CKStyle)

@end
