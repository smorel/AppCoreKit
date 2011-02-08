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
	//UIImageView *_imageView;
	CKImageLoader *_imageLoader;
	NSURL *_imageURL;
	UIImage *_defaultImage;	
	id<CKImageViewDelegate> _delegate;
	
	UIButton* _button;
	BOOL _interactive;
	
	NSTimeInterval _fadeInDuration;
}

@property (nonatomic, retain, readwrite) NSURL *imageURL;
@property (nonatomic, retain, readwrite) UIImage *defaultImage;
@property (nonatomic, retain, readonly) UIImage *image;
@property (nonatomic, assign, readwrite) UIViewContentMode imageViewContentMode;
@property (nonatomic, assign, readwrite) id<CKImageViewDelegate> delegate;
@property (nonatomic, assign, readwrite) NSTimeInterval fadeInDuration;
@property (nonatomic, assign, readwrite) BOOL interactive;

- (void)loadImageWithContentOfURL:(NSURL *)url;
- (void)reload;
- (void)reset;
- (void)cancel;

@end
