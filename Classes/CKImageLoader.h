//
//  CKImageLoader.h
//  CloudKit
//
//  Created by Olivier Collet on 10-07-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKWebRequest.h"

/** TODO
 */
extern NSString * const CKImageLoaderErrorDomain;

@class CKImageLoader;
typedef void(^CKImageLoaderCompletionBlock)(CKImageLoader* imageLoader, UIImage* image, BOOL loadedFromCache);
typedef void(^CKImageLoaderErrorBlock)(CKImageLoader* imageLoader, NSError* error);


/** TODO
 */
@interface CKImageLoader : NSObject <CKWebRequestDelegate> {
	id _delegate;
	CKWebRequest *_request;
	NSURL *_imageURL;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, copy) CKImageLoaderCompletionBlock completionBlock;
@property (nonatomic, copy) CKImageLoaderErrorBlock errorBlock;

- (id)initWithDelegate:(id)delegate;
- (void)loadImageWithContentOfURL:(NSURL *)url;
- (void)cancel;

+ (UIImage *)imageForURL:(NSURL *)URL;

@end

//

/** TODO
 */
@protocol CKImageLoaderDelegate

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached;
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error;

@end
