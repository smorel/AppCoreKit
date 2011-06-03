//
//  CKUIImage+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Style.h"

/* SUPPORTS :
 * CKStyleBackgroundStyle
 * CKStyleImage
 */

extern NSString* CKStyleImage;

@interface NSMutableDictionary (CKUIImageViewStyle)

- (UIImage*)image;

@end

@interface UIImageView (CKStyle)

@end
