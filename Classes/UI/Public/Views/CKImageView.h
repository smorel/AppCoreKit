//
//  CKImageView.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKImageLoader.h"



@class CKImageView;


/** 
 */
@protocol CKImageViewDelegate

///-----------------------------------
/// @name Reacting to Image View Events
///-----------------------------------

/**
 */
- (void)imageView:(CKImageView *)imageView didLoadImage:(UIImage *)image cached:(BOOL)cached;

/**
 */
- (void)imageView:(CKImageView *)imageView didFailLoadWithError:(NSError *)error;

@end



/** 
 */
typedef NS_ENUM(NSInteger, CKImageViewState){
	CKImageViewStateNone,
	CKImageViewStateSpinner,
	CKImageViewStateDefaultImage,
	CKImageViewStateImage
};

/** 
 */
typedef NS_ENUM(NSInteger, CKImageViewSpinnerStyle){
	CKImageViewSpinnerStyleWhiteLarge = UIActivityIndicatorViewStyleWhiteLarge,
    CKImageViewSpinnerStyleWhite = UIActivityIndicatorViewStyleWhite,
    CKImageViewSpinnerStyleGray = UIActivityIndicatorViewStyleGray,
	CKImageViewSpinnerStyleNone
};


/* COMMENT :
 In interactive mode, we replace the imageView by a UIButton to handle touchs.
 This has limitations :
 * the contentMode in the button does not respect the one we set for all states.
 We'll have to implements touchs and feedback drawing if we want to handle it correctly.
 */
@interface CKImageView : UIView <CKImageLoaderDelegate> 

///-----------------------------------
/// @name Customizing the image URL
///-----------------------------------

/**
 */
@property (nonatomic, retain, readwrite) NSURL *imageURL;

/**
 */
- (void)loadImageWithContentOfURL:(NSURL *)url;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic, retain, readwrite) UIImage *defaultImage;

/**
 */
@property (nonatomic, assign, readwrite) UIViewContentMode imageViewContentMode;

/**
 */
@property (nonatomic, assign, readwrite) NSTimeInterval fadeInDuration;

/**
 */
@property (nonatomic, assign, readwrite) BOOL interactive;

/**
 */
@property (nonatomic, assign, readwrite) CKImageViewSpinnerStyle spinnerStyle;

///-----------------------------------
/// @name Getting the image
///-----------------------------------

/**
 */
@property (nonatomic, retain, readonly) UIImage *image;

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property (nonatomic, assign, readwrite) id<CKImageViewDelegate> delegate;

///-----------------------------------
/// @name Getting the button and image views
///-----------------------------------

/**
 */
@property (nonatomic, retain, readonly) UIButton *button;

/**
 */
@property (nonatomic, retain, readonly) UIView *defaultImageView;

///-----------------------------------
/// @name Managing URL Requests
///-----------------------------------

/**
 */
- (void)reload;

/**
 */
- (void)reset;

/**
 */
- (void)cancel;

@end


/**
 */
@interface CKImageView (CKBindings)

///-----------------------------------
/// @name Bindings
///-----------------------------------

/**
 */
- (void)bindEvent:(UIControlEvents)controlEvents withBlock:(void (^)())block;

/**
 */
- (void)bindEvent:(UIControlEvents)controlEvents target:(id)target action:(SEL)selector;

@end
