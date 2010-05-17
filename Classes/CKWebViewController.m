//
//  CKWebViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKWebViewController.h"
#import "CKUINavigationControllerAdditions.h"
#import "CKConstants.h"
#import "CKBundle.h"
#import "CKUIToolbarAdditions.h"

@interface CKWebViewController ()

@property (nonatomic, readwrite, retain) NSURL *homeURL;
@property (nonatomic, readwrite, retain) UIWebView *webView;

@property (nonatomic, readwrite, retain) UIBarButtonItem *backButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *forwardButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *actionButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *spinnerItem;

@property (nonatomic, readwrite, retain) NSDictionary *navigationControllerStyles;

@end

//

@interface CKWebViewController (Private)
- (void)setBarButtonItem:(UIBarButtonItem *)buttonItem forItemType:(CKWebViewControllerButtonItemType)itemType target:(id)target action:(SEL)action;
@end

//

@implementation CKWebViewController

@synthesize homeURL = _homeURL;
@synthesize webView = _webView;

@synthesize backButtonItem = _backButtonItem;
@synthesize forwardButtonItem = _forwardButtonItem;
@synthesize refreshButtonItem = _refreshButtonItem;
@synthesize actionButtonItem = _actionButtonItem;
@synthesize spinnerItem = _spinnerItem;

@synthesize navigationControllerStyles = _navigationControllerStyles;
@synthesize showDocumentTitle = _showDocumentTitle;
@synthesize activityIndicatorViewStyle = _activityIndicatorViewStyle;

- (id)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		self.homeURL = url;
		self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	}
    return self;	
}

- (void)dealloc {
	self.webView = nil;
	self.homeURL = nil;
	self.backButtonItem = nil;
	self.forwardButtonItem = nil;
	self.refreshButtonItem = nil;
	self.actionButtonItem = nil;
	self.spinnerItem = nil;
	self.navigationControllerStyles = nil;
    [super dealloc];
}

#pragma mark View Management

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.autoresizingMask = CKUIViewAutoresizingFlexibleAll;

	// Set up the WebView
	
	self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.scalesPageToFit = YES;
	self.webView.delegate = self;
	
	[self.view addSubview:self.webView];

	// Setup the bar button items
	
	[self setButtonItemWithImage:[CKBundle imageForName:@"CKWebViewControllerGoBack.png"] type:CKWebViewControllerButtonItemBack target:nil action:nil];
	[self setButtonItemWithImage:[CKBundle imageForName:@"CKWebViewControllerGoForward.png"] type:CKWebViewControllerButtonItemForward target:nil action:nil];
	[self setButtonItemWithSystemItem:UIBarButtonSystemItemRefresh type:CKWebViewControllerButtonItemRefresh target:nil action:nil];
	
	UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorViewStyle] autorelease];
	[activityView startAnimating];
	self.spinnerItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
	self.spinnerItem.tag = CKWebViewControllerButtonItemRefresh;
	
	// Setup the toolbar
	
	UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	fixedSpace.width = 57.0f;
	UIBarButtonItem *flexiSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	NSMutableArray *items = [NSMutableArray arrayWithObjects:self.backButtonItem, fixedSpace, self.forwardButtonItem, flexiSpace, nil];
	
	if (self.actionButtonItem) {
		[items addObjectsFromArray:[NSArray arrayWithObjects:self.refreshButtonItem, fixedSpace, self.actionButtonItem, nil]];
	} else {
		[items addObject:self.refreshButtonItem];
	}
	
	[self setToolbarItems:items];
	
	//[NSArray arrayWithObjects:self.backButtonItem, fixedSpace, self.forwardButtonItem, flexiSpace, self.refreshButtonItem, nil] animated:NO];
	
	// Load the URL

	NSURLRequest *request = [NSURLRequest requestWithURL:self.homeURL];
	[self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Save the NavigationController styles
	self.navigationControllerStyles = [self.navigationController getStyles];

	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (self.webView.loading) [self.webView stopLoading];
	self.webView.delegate = nil;

	// Restore the NavigationController styles
	[self.navigationController setStyles:self.navigationControllerStyles animated:animated];
}

- (void)viewDidUnload {
	self.webView = nil;
	self.backButtonItem = nil;
	self.forwardButtonItem = nil;
	self.refreshButtonItem = nil;
	self.actionButtonItem = nil;
	self.spinnerItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Public API

- (NSURL *)currentURL {
	return [[NSURL URLWithString:[self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"]] standardizedURL];
}

- (void)setButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action {
	UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:target action:action] autorelease];
	[self setBarButtonItem:item forItemType:type target:target action:action];
}

- (void)setButtonItemWithImage:(UIImage *)image type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action {
	if (image == nil)
		return;
	UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action] autorelease];
	[self setBarButtonItem:item forItemType:type target:target action:action];
}

- (void)setSpinnerStyle:(UIActivityIndicatorViewStyle)style {
//	self.spinner.activityIndicatorViewStyle = style;
}

#pragma mark Toolbar Management

- (void)setBarButtonItem:(UIBarButtonItem *)buttonItem forItemType:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action {
	
	if (target) buttonItem.target = target;
	if (action) buttonItem.action = action;
	
	switch (type) {
		case CKWebViewControllerButtonItemBack:
			self.backButtonItem = buttonItem;
			self.backButtonItem.target = self;
			self.backButtonItem.action = @selector(actionGoBack);
			self.backButtonItem.enabled = NO;
			break;
		case CKWebViewControllerButtonItemForward:
			self.forwardButtonItem = buttonItem;
			self.forwardButtonItem.target = self;
			self.forwardButtonItem.action = @selector(actionGoForward);
			self.forwardButtonItem.enabled = NO;
			break;
		case CKWebViewControllerButtonItemRefresh:
			self.refreshButtonItem = buttonItem;
			self.refreshButtonItem.target = self;
			self.refreshButtonItem.action = @selector(actionRefresh);
			self.refreshButtonItem.enabled = YES;
			break;
		case CKWebViewControllerButtonItemAction:
			self.actionButtonItem = buttonItem;
			self.actionButtonItem.enabled = YES;
		default:
			break;
	}
	buttonItem.tag = type;	
}

- (void)actionGoBack {
	[self.webView goBack];
}
- (void)actionGoForward {
	[self.webView goForward];
}
- (void)actionRefresh {
	[self.webView reload];
}

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.navigationController.toolbar replaceItemWithTag:CKWebViewControllerButtonItemRefresh withItem:self.spinnerItem];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	// Update the title
	if (self.showDocumentTitle) {
		self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	}

	[self.navigationController.toolbar replaceItemWithTag:CKWebViewControllerButtonItemRefresh withItem:self.refreshButtonItem];	
	
	self.backButtonItem.enabled = self.webView.canGoBack;
	self.forwardButtonItem.enabled = self.webView.canGoForward;	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
