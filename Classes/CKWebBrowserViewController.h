//
//  CKWebViewController.h
//  CloudKit
//
//  Created by Olivier Collet, Fred Brunel on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKViewController.h"

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
@interface CKWebBrowserViewController : CKViewController

@property (nonatomic, readonly, retain) NSURL *homeURL;
@property (nonatomic, readonly, retain) NSURL *currentURL;
@property (nonatomic, readwrite, assign) BOOL showDocumentTitle;

- (id)initWithURL:(NSURL *)url;

- (void)setButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action;
- (void)setButtonItemWithImage:(UIImage *)image type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action;

@end
