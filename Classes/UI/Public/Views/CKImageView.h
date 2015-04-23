//
//  CKImageView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-23.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKImageCache.h"

/**
 */
typedef NS_ENUM(NSInteger, CKImageViewSpinnerStyle){
    CKImageViewSpinnerStyleWhiteLarge = UIActivityIndicatorViewStyleWhiteLarge,
    CKImageViewSpinnerStyleWhite = UIActivityIndicatorViewStyleWhite,
    CKImageViewSpinnerStyleGray = UIActivityIndicatorViewStyleGray,
    CKImageViewSpinnerStyleNone
};

/** An imageview providing the control interface for handling touch and the ability to load images from file or remote URL.
 This is backed by CKImageCache that allows to share image web requests for the same url between several instances of CKImageView reducing the network consumption. It also keep the loaded image in memory until no more CKImageView are displaying the image at the specified url.
 
 Cross fade animation can be parameterized when switching the image or receiving an image from a remote url. An optional default image can be set to be displayed while the image is fetched from a remote url as well as a spinner type for an optional activity indicator.
 */
@interface CKImageView : UIControl

///-----------------------------------
/// @name Managing the image
///-----------------------------------

/** defaultImage will be displayed while and image is loding from a remote URL
 */
@property (nonatomic, retain, readwrite) UIImage *defaultImage;

/** image can be set programatically or will be set internally when an image has been fetched from a file or remote URL
 */
@property (nonatomic, retain, readwrite) UIImage *image;

/**
 */
- (void)setImage:(UIImage*)image animated:(BOOL)animated;

///-----------------------------------
/// @name Managing image loading
///-----------------------------------

/** setting the imageURL will start a task for loding it from a file or a remote URL.
 A caching system is in place so that, if another instance of CKImageView2 already has fetched or starting fetching the same URL, it will reuse the same image or image loader to reduce network consumption and improve preformances. When no more CKImageView2 are displaying or fetching the image with the specified URL, the cached image or image loader is dismissed for the specified URL.
 */
@property (nonatomic, retain, readwrite) NSURL *imageURL;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------


/** Specifies a duration for cross fade between default image and the image loaded from the specified imageURL when fetched from a remote source or when setting the image. A value of 0 means no animation and the image will be displayed instantaneously.
 Default value is 0.25
 */
@property (nonatomic, assign, readwrite) NSTimeInterval fadeInDuration;

/** If the image at the specified imageURL is already available in cache or if it is a file URL, this allow to disable cross fade animation to get the imgae displayed instantaneously. This can be interesting in the context of CKImageView2 embedded in reusableViewController in tableView or collectionView.
 Default value is NO
 */
@property (nonatomic, assign, readwrite) BOOL animateLoadingOfImagesLoadedFromCache;

/** This specifies a type for displaying a UIActivityIndicatorView on top while fetching an image from a remote URL. UIActivityIndicatorView will be centered in the CKImageView2.
 Default value is CKImageViewSpinnerStyleNone
 */
@property (nonatomic, assign, readwrite) CKImageViewSpinnerStyle spinnerStyle;

/** An optional postProcess block can be set to modify the image before displaying it. It will be executed when receiving an image from the remote URL, the cache or if you set the image property.
 */
@property (nonatomic, copy) UIImage*(^postProcess)(UIImage* image);


@end



@interface CKImageView(Deprecated)

/* you can use setImageURL instead
*/
- (void)loadImageWithContentOfURL:(NSURL *)url;


/** You can use contentMode instead
 */
@property (nonatomic, assign, readwrite) UIViewContentMode imageViewContentMode;

/** You can use userInteractionEnabled instead
 */
@property (nonatomic, assign, readwrite) BOOL interactive;

@end