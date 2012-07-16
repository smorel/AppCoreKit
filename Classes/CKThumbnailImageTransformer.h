//
//  CKThumbnailImageTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKImageTransformer.h"


/** TODO
 */
@interface CKThumbnailImageTransformer : CKImageTransformer {
}

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL aspectFill;

+ (id)initWithDelegate:(id)delegate imageSize:(CGSize)imageSize aspectFill:(BOOL)aspectFill;

@end
