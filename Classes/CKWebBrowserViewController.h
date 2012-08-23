//
//  CKWebViewController.h
//  AppCoreKit
//
//  Created by Olivier Collet, Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKViewController.h"

/**
 */
typedef enum {
	CKWebViewControllerButtonItemBack,
	CKWebViewControllerButtonItemForward,
	CKWebViewControllerButtonItemRefresh,
	CKWebViewControllerButtonItemAction
} CKWebViewControllerButtonItemType;


/**
 */
@interface CKWebBrowserViewController : CKViewController

///-----------------------------------
/// @name Creating CKWebBrowserViewController Objects
///-----------------------------------

/**
 */
+ (CKWebBrowserViewController*)webBrowserWithUrl:(NSURL *)url;

///-----------------------------------
/// @name Initializing a CKWebBrowserViewController
///-----------------------------------

/**
 */
- (id)initWithURL:(NSURL *)url;

///-----------------------------------
/// @name Configuring a CKWebBrowserViewController
///-----------------------------------

/**
 */
@property (nonatomic, readwrite, retain) NSURL *homeURL;

/**
 */
@property (nonatomic, readonly, retain) NSURL *currentURL;

/**
 */
@property (nonatomic, readwrite, assign) BOOL showDocumentTitle;

///-----------------------------------
/// @name Customizing the toolbar
///-----------------------------------

/**
 */
- (void)setButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action;

/**
 */
- (void)setButtonItemWithImage:(UIImage *)image type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action;

/**
 */
@property (nonatomic, readonly, retain) UIBarButtonItem *backButtonItem;

/**
 */
@property (nonatomic, readonly, retain) UIBarButtonItem *forwardButtonItem;

/**
 */
@property (nonatomic, readonly, retain) UIBarButtonItem *refreshButtonItem;

/**
 */
@property (nonatomic, readonly, retain) UIBarButtonItem *actionButtonItem;

/**
 */
@property (nonatomic, readonly, retain) UIBarButtonItem *spinnerItem;

@end
