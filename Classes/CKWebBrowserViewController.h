//
//  CKWebViewController.h
//  CloudKit
//
//  Created by Olivier Collet, Fred Brunel on 10-02-03.
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
@property (nonatomic, readonly, retain) NSURL *homeURL;

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

@end
