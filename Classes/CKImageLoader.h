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
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSURL *imageURL;

@property (nonatomic, assign) CGSize imageSize DEPRECATED_ATTRIBUTE; 
@property (nonatomic, assign) BOOL aspectFill DEPRECATED_ATTRIBUTE; 

- (id)initWithDelegate:(id)delegate;
- (void)loadImageWithContentOfURL:(NSURL *)url;
- (void)cancel;

@end


@interface CKImageLoader (Deprecated)

+ (UIImage *)imageForURL:(NSURL *)url DEPRECATED_ATTRIBUTE;
+ (UIImage *)imageForURL:(NSURL *)url withSize:(CGSize)size DEPRECATED_ATTRIBUTE;

@end

//

@protocol CKImageLoaderDelegate

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached;
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error;

@end
