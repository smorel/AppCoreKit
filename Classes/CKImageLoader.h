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


/** TODO
 */
@interface CKImageLoader : NSObject <CKWebRequestDelegate> {
	id _delegate;
	CKWebRequest *_request;
	NSURL *_imageURL;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSURL *imageURL;

- (id)initWithDelegate:(id)delegate;
- (void)loadImageWithContentOfURL:(NSURL *)url;
- (void)cancel;

+ (UIImage *)imageForURL:(NSURL *)URL;

@end

//

/** TODO
 */
@interface CKImageLoader (Deprecated)

@property (nonatomic, assign) CGSize imageSize DEPRECATED_ATTRIBUTE; 
@property (nonatomic, assign) BOOL aspectFill DEPRECATED_ATTRIBUTE; 

+ (UIImage *)imageForURL:(NSURL *)url withSize:(CGSize)size DEPRECATED_ATTRIBUTE;

@end

//

/** TODO
 */
@protocol CKImageLoaderDelegate

- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached;
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error;

@end
