//
//  CKImageCache.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-23.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@protocol CKImageCacheDelegate <NSObject>

/**
 */
- (void)imageWasAlreadyFetched:(UIImage*)image;

/**
 */
- (void)didFetchImage:(UIImage*)image;

/**
 */
- (void)didFailFetchingImage:(NSError*)error;

@end


/**
 */
@interface CKImageCache : NSObject

/**
 */
- (void)registerDelegate:(id<CKImageCacheDelegate>)delegate withImageURL:(NSURL*)url;

/**
 */
- (void)unregisterDelegate:(id<CKImageCacheDelegate>)delegate withImageURL:(NSURL*)url;

/**
 */
- (void)reloadImageAtUrl:(NSURL*)url;

@end
