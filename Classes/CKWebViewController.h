//
//  CKWebViewController.h
//  YellowPages
//
//  Created by Olivier Collet on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CKWebViewButtonBack,
	CKWebViewButtonForward,
	CKWebViewButtonReload
} CKWebViewButton;

@interface CKWebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *_webView;
	
	NSURL *_homeURL;
	BOOL _showURLInTitle;
	
	UIBarButtonItem *_backButton;
	UIBarButtonItem *_forwardButton;
	UIBarButtonItem *_reloadButton;
	UIActivityIndicatorView *_spinner;
	
	NSMutableArray *_toolbarButtonsLoading;
	NSMutableArray *_toolbarButtonsStatic;

	NSDictionary *_navigationControllerStyles;
}

@property (readonly, nonatomic, retain) NSURL *homeURL;
@property (readonly, nonatomic) NSURL *currentURL;
@property (nonatomic, assign, getter=isURLInTitle, setter=showURLInTitle) BOOL _showURLInTitle;

- (id)initWithURL:(NSURL *)url;

- (void)setActionButtonWithStyle:(UIBarButtonSystemItem)style action:(SEL)action target:(id)target;
- (void)setImage:(UIImage *)image forButton:(CKWebViewButton)button;
- (void)setSpinnerStyle:(UIActivityIndicatorViewStyle)style;

@end
