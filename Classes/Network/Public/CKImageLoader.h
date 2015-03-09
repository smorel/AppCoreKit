//
//  CKImageLoader.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKWebRequest.h"

/**
 */
extern NSString * const CKImageLoaderErrorDomain;

@class CKImageLoader;
typedef void(^CKImageLoaderCompletionBlock)(CKImageLoader* imageLoader, UIImage* image, BOOL loadedFromCache);
typedef void(^CKImageLoaderErrorBlock)(CKImageLoader* imageLoader, NSError* error);


/**
 */
@interface CKImageLoader : NSObject

///-----------------------------------
/// @name Managing the Delegate 
///-----------------------------------

/** 
 */
@property (nonatomic, assign) id delegate;

/** 
 */
- (id)initWithDelegate:(id)delegate;

///-----------------------------------
/// @name Reacting to ImageLoader events 
///-----------------------------------

/** 
 */
@property (nonatomic, copy) CKImageLoaderCompletionBlock completionBlock;
/** 
 */
@property (nonatomic, copy) CKImageLoaderErrorBlock errorBlock;

/**
 */
@property (nonatomic, copy) UIImage*(^postProcess)(UIImage* image);

///-----------------------------------
/// @name Managing the URL and Requests
///-----------------------------------

/** 
 */
@property (nonatomic, retain) NSURL *imageURL;

/** 
 */
- (void)loadImageWithContentOfURL:(NSURL *)url;

/** 
 */
- (void)cancel;

@end

//

/**
 */
@protocol CKImageLoaderDelegate

///-----------------------------------
/// @name Reacting to ImageLoader events 
///-----------------------------------

/** 
 */
- (void)imageLoader:(CKImageLoader *)imageLoader didLoadImage:(UIImage *)image cached:(BOOL)cached;

/** 
 */
- (void)imageLoader:(CKImageLoader *)imageLoader didFailWithError:(NSError *)error;

@end
