//
//  CKImageLoader.h
//  CloudKit
//
//  Created by Olivier Collet on 10-07-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CKWebRequest2.h"

@interface CKImageLoader : NSObject <CKWebRequestDelegate> {
	id _delegate;
	CKWebRequest2 *_request;
	NSURL *_imageURL;
	CGSize _imageSize;
	BOOL _aspectFill;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL aspectFill;

- (id)initWithDelegate:(id)delegate;
- (void)loadImageWithContentOfURL:(NSURL *)url;
- (void)cancel;

+ (UIImage *)imageForURL:(NSURL *)url;
+ (UIImage *)imageForURL:(NSURL *)url withSize:(CGSize)size;

@end

//

@protocol CKImageLoaderDelegate

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached;
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error;

@end
