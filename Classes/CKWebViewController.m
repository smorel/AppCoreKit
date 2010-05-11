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

#define CKBarButtonItemFlexibleSpace [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]

@interface CKWebViewController ()

@property (nonatomic, readwrite, retain) NSURL *homeURL;
@property (nonatomic, readwrite, retain) UIWebView *webView;

@property (nonatomic, readwrite, retain) UIBarButtonItem *backButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *forwardButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *reloadButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *actionButtonItem;

@property (nonatomic, readwrite, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, readwrite, retain) NSMutableArray *toolbarButtonsLoading;
@property (nonatomic, readwrite, retain) NSMutableArray *toolbarButtonsStatic;
@property (nonatomic, readwrite, retain) NSDictionary *navigationControllerStyles;

@end

//

@interface CKWebViewController (Private)
- (void)setupToolbar;
@end

//

@implementation CKWebViewController

@synthesize homeURL = _homeURL;
@synthesize webView = _webView;
@synthesize backButtonItem = _backButtonItem;
@synthesize forwardButtonItem = _forwardButtonItem;
@synthesize reloadButtonItem = _reloadButtonItem;
@synthesize actionButtonItem = _actionButtonItem;
@synthesize spinner = _spinner;
@synthesize toolbarButtonsLoading = _toolbarButtonsLoading;
@synthesize toolbarButtonsStatic = _toolbarButtonsStatic;
@synthesize navigationControllerStyles = _navigationControllerStyles;
@synthesize showDocumentTitle = _showDocumentTitle;

- (id)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		self.homeURL = url;

		// Create the toolbar buttons

		[self setImage:[CKBundle imageForName:@"CKWebViewControllerGoBack.png"] forButtonType:CKWebViewControllerButtonTypeBack];
		[self setImage:[CKBundle imageForName:@"CKWebViewControllerGoForward.png"] forButtonType:CKWebViewControllerButtonTypeForward];
		
		self.reloadButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionReload)] autorelease];
		
		self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
		[self.spinner startAnimating];
		
		[self setupToolbar];
	}
    return self;	
}

- (void)dealloc {
	self.webView = nil;
	self.homeURL = nil;
	self.backButtonItem = nil;
	self.forwardButtonItem = nil;
	self.reloadButtonItem = nil;
	self.actionButtonItem = nil;
	self.spinner = nil;
	self.toolbarButtonsStatic = nil;
	self.toolbarButtonsLoading = nil;
	self.navigationControllerStyles = nil;
    [super dealloc];
}

#pragma mark View Management

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.autoresizingMask = CKUIViewAutoresizingFlexibleAll;

	// Set up the WebView
	
	self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	self.webView.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
	self.webView.scalesPageToFit = YES;
	self.webView.delegate = self;
	
	[self.view addSubview:_webView];

	// Load the URL

	NSURLRequest *request = [NSURLRequest requestWithURL:self.homeURL];
	[self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Save the NavigationController styles
	
	self.navigationControllerStyles = [self.navigationController getStyles];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
		
	// Display the toolbar

	[self setupToolbar];
	[self setToolbarItems:self.toolbarButtonsStatic animated:animated];
	[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (self.webView.loading) [self.webView stopLoading];
	self.webView.delegate = nil;

	// Restore the NavigationController styles
	[self.navigationController setStyles:self.navigationControllerStyles animated:animated];

	[super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	self.webView = nil;
	self.backButtonItem = nil;
	self.forwardButtonItem = nil;
	self.reloadButtonItem = nil;
	self.actionButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Public API

- (NSURL *)currentURL {
	return [[NSURL URLWithString:[self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"]] standardizedURL];
}

- (void)setActionButtonWithStyle:(UIBarButtonSystemItem)style action:(SEL)action target:(id)target {
	self.actionButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:target action:action] autorelease];
//	[self.toolbarButtonsStatic addObject:CKBarButtonItemFlexibleSpace];
//	[self.toolbarButtonsStatic addObject:actionButton];
//	[self.toolbarButtonsLoading addObject:CKBarButtonItemFlexibleSpace];
//	[self.toolbarButtonsLoading addObject:actionButton];
}

- (void)setImage:(UIImage *)image forButtonType:(CKWebViewControllerButtonType)buttonType {
	if (image == nil) return;
	
	UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc] initWithImage:image 
																	   style:UIBarButtonItemStylePlain 
																	  target:self 
																	  action:nil] autorelease];
	switch (buttonType) {
		case CKWebViewControllerButtonTypeBack:
			self.backButtonItem = barButtonItem;
			self.backButtonItem.action = @selector(actionGoBack);
			break;
		case CKWebViewControllerButtonTypeForward:
			self.forwardButtonItem = barButtonItem;
			self.forwardButtonItem.action = @selector(actionGoForward);
			break;
		case CKWebViewControllerButtonTypeReload:
			self.reloadButtonItem = barButtonItem;
			self.reloadButtonItem.action = @selector(actionReload);
			break;
		default:
			break;
	}
	
	[self setupToolbar];
}

- (void)setSpinnerStyle:(UIActivityIndicatorViewStyle)style {
	self.spinner.activityIndicatorViewStyle = style;
}

#pragma mark Toolbar Management

- (void)setupToolbar {
	self.backButtonItem.enabled = self.webView.canGoBack;
	self.forwardButtonItem.enabled = self.webView.canGoForward;
	
	self.toolbarButtonsStatic = [[NSMutableArray alloc] initWithObjects:self.backButtonItem, CKBarButtonItemFlexibleSpace, self.forwardButtonItem, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, self.reloadButtonItem, nil];
	UIBarButtonItem *spinnerItem = [[[UIBarButtonItem alloc] initWithCustomView:self.spinner] autorelease];
	self.toolbarButtonsLoading = [[NSMutableArray alloc] initWithObjects:self.backButtonItem, CKBarButtonItemFlexibleSpace, self.forwardButtonItem, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, spinnerItem, nil];
	
	if (self.actionButtonItem) {
		[self.toolbarButtonsStatic addObject:self.actionButtonItem];
		[self.toolbarButtonsLoading addObject:self.actionButtonItem];
	}
	
	[self setToolbarItems:([self.webView isLoading] ? self.toolbarButtonsLoading : self.toolbarButtonsStatic) animated:NO];
}

- (void)actionGoBack {
	[self.webView goBack];
}
- (void)actionGoForward {
	[self.webView goForward];
}
- (void)actionReload {
	[self.webView reload];
}

#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self setupToolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self setupToolbar];

	// Update the title
	if (self.showDocumentTitle) {
		self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self setupToolbar];
}

@end
