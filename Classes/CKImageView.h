//
//  CKImageView.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKImageLoader.h"
#import "CKSignal.h"



/* COMMENT :
     In interactive mode, we replace the imageView by a UIButton to handle touchs.
     This has limitations :
       * the contentMode in the button does not respect the one we set for all states.
     We'll have to implements touchs and feedback drawing if we want to handle it correctly.
 */


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
	
	UIImageView* _imageView;
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
@property (nonatomic, retain, readonly) UIButton *button;

- (void)loadImageWithContentOfURL:(NSURL *)url;
- (void)reload;
- (void)reset;
- (void)cancel;

@end
