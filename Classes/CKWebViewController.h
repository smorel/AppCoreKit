//
//  CKWebViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CKWebViewControllerButtonTypeBack,
	CKWebViewControllerButtonTypeForward,
	CKWebViewControllerButtonTypeReload
} CKWebViewControllerButtonType;

@interface CKWebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *_webView;
	NSURL *_homeURL;
	UIBarButtonItem *_backButtonItem;
	UIBarButtonItem *_forwardButtonItem;
	UIBarButtonItem *_reloadButtonItem;
	UIBarButtonItem *_actionButtonItem;
	UIActivityIndicatorView *_spinner;
	NSMutableArray *_toolbarButtonsLoading;
	NSMutableArray *_toolbarButtonsStatic;
	NSDictionary *_navigationControllerStyles;
	BOOL _showDocumentTitle;
}

@property (nonatomic, readonly, retain) NSURL *homeURL;
@property (nonatomic, readonly, retain) NSURL *currentURL;
@property (nonatomic, readwrite, assign) BOOL showDocumentTitle;

- (id)initWithURL:(NSURL *)url;

- (void)setActionButtonWithStyle:(UIBarButtonSystemItem)style action:(SEL)action target:(id)target;
- (void)setImage:(UIImage *)image forButtonType:(CKWebViewControllerButtonType)buttonType;
- (void)setSpinnerStyle:(UIActivityIndicatorViewStyle)style;

@end
