//
//  CKImageView.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CKWebRequest.h>

@class CKImageView;

@protocol CKImageViewDelegate

- (void)imageViewDidFinishLoading:(CKImageView *)imageView;
- (void)imageView:(CKImageView *)imageView didFailLoadingWithError:(NSError *)error;

@end

//

@interface CKImageView : UIView <CKWebRequestDelegate> {
	CKWebRequest *_request;
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
