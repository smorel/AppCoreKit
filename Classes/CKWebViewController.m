//
//  CKWebViewController.m
//  YellowPages
//
//  Created by Olivier Collet on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKWebViewController.h"
#import "CKUINavigationControllerAdditions.h"
#import "CKConstants.h"

#define CKBarButtonItemFlexibleSpace [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]

@interface CKWebViewController ()
@property (nonatomic, readwrite, retain) NSURL *homeURL;
@property (nonatomic, readwrite, retain) UIBarButtonItem *backButton;
@property (nonatomic, readwrite, retain) UIBarButtonItem *forwardButton;
@property (nonatomic, readwrite, retain) UIBarButtonItem *reloadButton;
@property (nonatomic, readwrite, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, readwrite, retain) NSMutableArray *toolbarButtonsLoading;
@property (nonatomic, readwrite, retain) NSMutableArray *toolbarButtonsStatic;
@end


@interface CKWebViewController ()
@property (nonatomic, retain) NSString *HTMLString;
@property (nonatomic, retain) NSURL *baseURL;
- (void)generateToolbar;
- (void)updateToolbar;
@end



@implementation CKWebViewController

@synthesize homeURL = _homeURL;
@synthesize HTMLString = _HTMLString;
@synthesize baseURL = _baseURL;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize reloadButton = _reloadButton;
@synthesize spinner = _spinner;
@synthesize toolbarButtonsLoading = _toolbarButtonsLoading;
@synthesize toolbarButtonsStatic = _toolbarButtonsStatic;

- (void)setup {
	_showURLInTitle = YES;
	
	// Create the toolbar buttons
	[self setImage:[UIImage imageNamed:@"CKWebViewController-goBack.png"] forButton:CKWebViewButtonBack];
	[self setImage:[UIImage imageNamed:@"CKWebViewController-goForward.png"] forButton:CKWebViewButtonForward];
	self.reloadButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)] autorelease];
	self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	
	[self generateToolbar];	
}

- (id)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		self.homeURL = url;
		[self setup];
	}
    return self;	
}

- (id)initWithHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	if (self = [super init]) {
		self.HTMLString = string;
		self.baseURL = baseURL;
		[self setup];
	}
    return self;	
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.autoresizingMask = CKUIViewAutoresizingFlexibleAll;

	// Set up the WebView
	_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	_webView.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
	_webView.scalesPageToFit = YES;
	_webView.delegate = self;
	[self.view addSubview:_webView];

	// Load the URL
	if (_homeURL) {
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_homeURL];
		[_webView loadRequest:request];
		[request release];
	}
	
	// Load the HTML string
	if (self.HTMLString) {
		[_webView loadHTMLString:self.HTMLString baseURL:self.baseURL];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Save the NavigationController styles
	_navigationControllerStyles = [[self.navigationController getStyles] retain];

	[self.navigationController setNavigationBarHidden:NO animated:animated];
	
	[self updateToolbar];
	[self setToolbarItems:_toolbarButtonsStatic animated:animated];

	// Display the toolbar
	[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (_webView.loading) [_webView stopLoading];
	_webView.delegate = nil;

	// Restore the NavigationController styles
	[self.navigationController setStyles:_navigationControllerStyles animated:animated];

	[super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	[_webView release];
	_webView = nil;
	[_backButton release];
	_backButton = nil;
	[_forwardButton release];
	_forwardButton = nil;
}

- (void)dealloc {
	self.HTMLString = nil;
	self.baseURL = nil;
	[_webView release];
	[_homeURL release];
	[_backButton release];
	[_forwardButton release];
	[_toolbarButtonsStatic release];
	[_toolbarButtonsLoading release];
	[_navigationControllerStyles release];
    [super dealloc];
}

- (void)setActionButtonWithStyle:(UIBarButtonSystemItem)style action:(SEL)action target:(id)target {
	UIBarButtonItem *actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:target action:action] autorelease];
	[_toolbarButtonsStatic addObject:CKBarButtonItemFlexibleSpace];
	[_toolbarButtonsStatic addObject:actionButton];
	[_toolbarButtonsLoading addObject:CKBarButtonItemFlexibleSpace];
	[_toolbarButtonsLoading addObject:actionButton];
}

- (NSURL *)currentURL {
	return [[NSURL URLWithString:[_webView stringByEvaluatingJavaScriptFromString:@"window.location.href"]] standardizedURL];
}

#pragma mark -
#pragma mark Toolbar

- (void)updateToolbar {
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
	
	[self generateToolbar];
	if ([_webView isLoading]) [self setToolbarItems:self.toolbarButtonsLoading animated:NO];
	else [self setToolbarItems:self.toolbarButtonsStatic animated:NO];
}

- (void)goBack {
	[_webView goBack];
}
- (void)goForward {
	[_webView goForward];
}
- (void)reload {
	[_webView reload];
}


#pragma mark -
#pragma mark Toolbar Customization

- (void)generateToolbar {
	self.toolbarButtonsStatic = [[NSMutableArray alloc] initWithObjects:self.backButton, CKBarButtonItemFlexibleSpace, self.forwardButton, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, self.reloadButton, nil];
	[self.spinner startAnimating];
	UIBarButtonItem *loadingItem = [[[UIBarButtonItem alloc] initWithCustomView:self.spinner] autorelease];
	self.toolbarButtonsLoading = [[NSMutableArray alloc] initWithObjects:self.backButton, CKBarButtonItemFlexibleSpace, self.forwardButton, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, CKBarButtonItemFlexibleSpace, loadingItem, nil];
}

- (void)setImage:(UIImage *)image forButton:(CKWebViewButton)button {
	if (image == nil) return;

	UIButton *btn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)] autorelease];
	[btn setImage:image forState:UIControlStateNormal];
	
	switch (button) {
		case CKWebViewButtonBack:
			[btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
			self.backButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
			break;
		case CKWebViewButtonForward:
			[btn addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
			self.forwardButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
			break;
		case CKWebViewButtonReload:
			[btn addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
			self.reloadButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
			break;
		default:
			break;
	}
	
	[self updateToolbar];
}

- (void)setSpinnerStyle:(UIActivityIndicatorViewStyle)style {
	_spinner.activityIndicatorViewStyle = style;
}


#pragma mark -
#pragma mark WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if([request.URL isEqual:[NSURL URLWithString:@"about:blank"]] && navigationType == UIWebViewNavigationTypeReload) return NO;
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self updateToolbar];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self updateToolbar];

	// Update the title
	if (_showURLInTitle) self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self updateToolbar];
}


@end
