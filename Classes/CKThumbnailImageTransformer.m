//
//  CKThumbnailImageTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel8.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKThumbnailImageTransformer.h"
#import "CKUIImage+Transformations.h"

@implementation CKThumbnailImageTransformer
@synthesize imageSize;
@synthesize aspectFill;

+ (id)initWithDelegate:(id)delegate imageSize:(CGSize)imageSize aspectFill:(BOOL)aspectFill{
	CKThumbnailImageTransformer* transformer = [[[CKThumbnailImageTransformer alloc]initWithDelegate:delegate]autorelease];
	transformer.imageSize = imageSize;
	transformer.aspectFill = aspectFill;
	return transformer;
}

#pragma mark Overloadable functions
- (id)cacheKeyForUrl:(NSURL*)url{
	return [NSString stringWithFormat:@"%@-%fx%f", url, imageSize.width, imageSize.height];
}

- (UIImage*)transformImage:(UIImage*)image{
	return [image imageThatFits:self.imageSize crop:self.aspectFill];
}

@end
