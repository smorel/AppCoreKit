//
//  CKWebViewController.h
//  YellowPages
//
//  Created by Olivier Collet on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CKUIViewController.h"

/** TODO
 */
@interface CKWebViewController : CKUIViewController

@property (readonly, nonatomic) NSURL *currentURL;
@property (nonatomic, readonly, retain) UIWebView *webView;
@property (nonatomic, assign) id<UIWebViewDelegate> delegate; //Forward UIWebViewDelegate events

- (void)loadURL:(NSURL*)URL withCompletionBlock:(void (^)(UIWebView *webView, NSError *error))completion;

@end
