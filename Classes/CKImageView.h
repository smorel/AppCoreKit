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
	NSString *_imageURL;
	UIImage *_image;
	BOOL _aspectFill;
	UIColor *_borderColor;
	CGFloat _cornerRadius;
	
	id<CKImageViewDelegate> _delegate;
}

@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain, readonly) UIImage *image;
@property (nonatomic, assign) BOOL aspectFill;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) id<CKImageViewDelegate> delegate;

- (void)reload;
- (void)cancel;

@end
