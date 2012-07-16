//
//  CKImageTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKImageLoader.h"

@class CKImageTransformer;

/** TODO
 */
@protocol CKImageTransformerDelegate
-(void)imageTransformer:(CKImageTransformer*)transformer didTransformImage:(UIImage*)image cached:(BOOL)cached;
-(void)imageTransformer:(CKImageTransformer*)transformer didFailWithError:(NSError *)error;
@end


/** TODO
 */
@interface CKImageTransformer : NSOperation<CKImageLoaderDelegate> {
	CKImageLoader* _imageLoader;
	id<CKImageTransformerDelegate> _delegate;
	UIImage* _originalImage;
	NSURL* _imageURL;
}

@property (nonatomic, retain) CKImageLoader* imageLoader;
@property (nonatomic, retain) id<CKImageTransformerDelegate> delegate;
@property (nonatomic, retain) UIImage* originalImage;

- (id)initWithDelegate:(id)theDelegate;
- (void)imageForURL:(NSURL*)url;

- (id)cacheKeyForUrl:(NSURL*)url;
- (UIImage*)transformImage:(UIImage*)image;

- (void)cancel;

@end
