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
typedef enum {
	CKWebViewButtonBack,
	CKWebViewButtonForward,
	CKWebViewButtonReload
} CKWebViewButton;


/** TODO
 */
@interface CKWebViewController : CKUIViewController <UIWebViewDelegate> {
	UIWebView *_webView;
	UIToolbar* _webViewToolbar;
	
	NSURL *_homeURL;
	NSString *_HTMLString;
	NSURL *_baseURL;

	BOOL _showURLInTitle;
	BOOL _hidesToolbar;
	
	UIBarButtonItem *_backButton;
	UIBarButtonItem *_forwardButton;
	UIBarButtonItem *_reloadButton;
	UIActivityIndicatorView *_spinner;
	
	NSMutableArray *_toolbarButtonsLoading;
	NSMutableArray *_toolbarButtonsStatic;
	
	NSString *_onLoadScript;
	
	CGSize _minContentSizeForViewInPopover;
	CGSize _maxContentSizeForViewInPopover;
	
	BOOL _canBeDismissed;
}

@property (nonatomic, retain) NSURL *homeURL;
@property (readonly, nonatomic) NSURL *currentURL;
@property (nonatomic, assign, getter=isURLInTitle, setter=showURLInTitle:) BOOL _showURLInTitle;
@property (nonatomic, assign) BOOL hidesToolbar;
@property (nonatomic, retain) NSString *onLoadScript;
@property (nonatomic, assign) CGSize minContentSizeForViewInPopover;
@property (nonatomic, assign) CGSize maxContentSizeForViewInPopover;
@property (nonatomic, assign) BOOL canBeDismissed;
@property (nonatomic, retain) UIToolbar* webViewToolbar;

- (id)initWithURL:(NSURL *)url;
- (id)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (void)setActionButtonWithStyle:(UIBarButtonSystemItem)style action:(SEL)action target:(id)target;
- (void)setImage:(UIImage *)image forButton:(CKWebViewButton)button;
- (void)setSpinnerStyle:(UIActivityIndicatorViewStyle)style;

@end
