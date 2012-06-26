//
//  CKWebViewController.h
//  YellowPages
//
//  Created by Olivier Collet on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CKViewController.h"

/**
 */
@interface CKWebViewController : CKViewController

///-----------------------------------
/// @name Initializing a CKWebBrowserViewController
///-----------------------------------

/**
 */
- (id)initWithURL:(NSURL*)URL;

/**
 */
- (id)initWithURL:(NSURL*)URL withCompletionBlock:(void (^)(UIWebView *webView, NSError *error))completion;

///-----------------------------------
/// @name Getting the web view status
///-----------------------------------

/**
 */
@property (readonly, nonatomic) NSURL *currentURL;

/**
 */
@property (nonatomic, copy) void (^completionBlock)(UIWebView *webView, NSError *error);

///-----------------------------------
/// @name Loading an URL
///-----------------------------------

/**
 */
- (void)loadURL:(NSURL*)URL;

///-----------------------------------
/// @name Getting the web view
///-----------------------------------

/**
 */
@property (nonatomic, readonly, retain) UIWebView *webView;


///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/** /Forward UIWebViewDelegate events
 */
@property (nonatomic, assign) id<UIWebViewDelegate> delegate;

@end
