//
//  CKImageView.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKImageLoader.h"

@class CKImageView;

@protocol CKImageViewDelegate

- (void)imageView:(CKImageView *)imageView didLoadImage:(UIImage *)image cached:(BOOL)cached;
- (void)imageView:(CKImageView *)imageView didFailLoadWithError:(NSError *)error;

@end

//

@interface CKImageView : UIView <CKImageLoaderDelegate> {
	CKImageLoader *_imageLoader;
	NSURL *_imageURL;
	UIImage *_defaultImage;
	UIImage *_image;
	BOOL _aspectFill;
	
	id<CKImageViewDelegate> _delegate;
}

@property (nonatomic, retain, readonly) NSURL *imageURL;
@property (nonatomic, retain) UIImage *defaultImage;
@property (nonatomic, retain, readonly) UIImage *image;
@property (nonatomic, assign) BOOL aspectFill;
@property (nonatomic, assign) id<CKImageViewDelegate> delegate;

- (void)loadImageWithContentOfURL:(NSURL *)url;
- (void)reload;
- (void)reset;
- (void)cancel;

@end
