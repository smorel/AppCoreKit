//
//  CKImageCache.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-23.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Singleton.h"

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

///-----------------------------------
/// @name Managing remote images
///-----------------------------------

/** Register a delegate to fetch or reuse an image at a specific url. If the image is not loaded yet, the loading will be shared through all the registered delegates for the specified url. At the end of the loading, all the registered delegates will be notified that the image is ready using the didFetchImage: method. If the image was alredy loaded, they will be notified using the imageWasAlreadyFetched: method.
 */
- (void)registerDelegate:(id<CKImageCacheDelegate>)delegate withImageURL:(NSURL*)url;

/** Unregisters a delegate for the specified url. When no more delegates are registered, the loading is cancelled if it was still in process and the loaded image is released if it was already fetched.
 */
- (void)unregisterDelegate:(id<CKImageCacheDelegate>)delegate withImageURL:(NSURL*)url;

/** Force reloading an image at the specified url. All the registered delegates will be notified of the newly loaded image using didFetchImage: method.
 */
- (void)reloadImageAtUrl:(NSURL*)url;

/** Returns the image loaded at the specified url if they are delegates registered and the image has already been fetched. Returns nil in other cases.
 */
- (UIImage*)imageWithUrl:(NSURL*)url;


///-----------------------------------
/// @name Managing local images
///-----------------------------------

/** Register an image with an associated handler. handler serves the purpose of retaining the image with the specified identifier until no more handlers are registered.
 */
- (void)registerHandler:(id)handler image:(UIImage*)image withIdentifier:(NSString*)identifier;

/** Unregister the specified handler for the specified identifier. If no more habdler are registered for this idntifier, the image will be released.
 */
- (void)unregisterHandler:(id)handler withIdentifier:(NSString*)identifier;

/** Returns the image with the specified identifier. If no handler are registered for this identifier, it will return nil.
 */
- (UIImage*)imageWithIdentifier:(NSString*)identifier;


///-----------------------------------
/// @name Generating or fetching local images
///-----------------------------------

/** if the cacheIdentifier is different than the handler's handlerCacheIdentifier Property, the handler is unregisters from image cache for the previous identifier.
 then, if the image with the specified cacheIdentifier already exists in cahce, it is returned and the handler is registered for the cacheIdentifier.
 If the image doesn't exists, it is created by calling the generateImageBlock and then returned while the handler is registered for this cache identifier with the created image.
 */
- (UIImage*)findOrCreateImageWithHandler:(id)handler handlerCacheIdentifierProperty:(NSString*)keypath cacheIdentifier:(NSString*)cacheIdentifier generateImageBlock:(UIImage*(^)())generateImageBlock;

@end
