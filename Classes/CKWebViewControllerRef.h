//
//  CKWebViewController.h
//  CloudKit
//
//  Created by Olivier Collet, Fred Brunel on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** TODO
 */
typedef enum {
	CKWebViewControllerButtonItemBack,
	CKWebViewControllerButtonItemForward,
	CKWebViewControllerButtonItemRefresh,
	CKWebViewControllerButtonItemAction
} CKWebViewControllerButtonItemType;


/** TODO
 */
@interface CKWebViewControllerRef : UIViewController <UIWebViewDelegate> {
	UIWebView *_webView;
	NSURL *_homeURL;
	
	UIBarButtonItem *_backButtonItem;
	UIBarButtonItem *_forwardButtonItem;
	UIBarButtonItem *_refreshButtonItem;
	UIBarButtonItem *_actionButtonItem;
	UIBarButtonItem *_spinnerItem;
	
	UIActivityIndicatorViewStyle _activityIndicatorViewStyle;
	NSDictionary *_navigationControllerStyles;
	BOOL _showDocumentTitle;
}

@property (nonatomic, readonly, retain) NSURL *homeURL;
@property (nonatomic, readonly, retain) NSURL *currentURL;
@property (nonatomic, readwrite, assign) BOOL showDocumentTitle;
@property (nonatomic, readwrite, assign) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

- (id)initWithURL:(NSURL *)url;

- (void)setButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action;
- (void)setButtonItemWithImage:(UIImage *)image type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action;

@end
