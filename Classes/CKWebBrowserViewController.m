//
//  CKWebViewController.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKWebBrowserViewController.h"
#import "UIView+AutoresizingMasks.h"
#import "CKWebViewController.h"
#import "UIView+Name.h"
#import "NSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>

@interface CKWebBrowserViewController () <UIWebViewDelegate>

@property (nonatomic, readwrite, retain) CKWebViewController *webController;

@property (nonatomic, readwrite, retain) UIBarButtonItem *backButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *forwardButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *actionButtonItem;
@property (nonatomic, readwrite, retain) UIBarButtonItem *spinnerItem;
@property (nonatomic, readwrite, retain) UIWebView *webView;

@property (nonatomic, assign) BOOL wasUsingToolbar;
@property (nonatomic, assign) BOOL wasUsingNavigationbar;

@end

//

@interface CKWebBrowserViewController (Private)
- (void)setBarButtonItem:(UIBarButtonItem *)buttonItem forItemType:(CKWebViewControllerButtonItemType)itemType target:(id)target action:(SEL)action;
@end

//

@implementation CKWebBrowserViewController

@synthesize homeURL = _homeURL, webController;
@synthesize backButtonItem, forwardButtonItem, refreshButtonItem, actionButtonItem, spinnerItem;
@synthesize showDocumentTitle;
@synthesize wasUsingToolbar, wasUsingNavigationbar,autoManageNavigationAndToolBar;
@synthesize webView;

- (id)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		self.homeURL = url;
        self.autoManageNavigationAndToolBar = YES;
	}
    return self;	
}

- (void)dealloc {
	self.webController = nil;
	self.homeURL = nil;
	self.backButtonItem = nil;
	self.forwardButtonItem = nil;
	self.refreshButtonItem = nil;
	self.actionButtonItem = nil;
	self.spinnerItem = nil;
    self.webView = nil;
    [super dealloc];
}

+ (CKWebBrowserViewController*)webBrowserWithUrl:(NSURL *)url{
    return [[[CKWebBrowserViewController alloc]initWithURL:url]autorelease];
}

#pragma mark View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webController = [[[CKWebViewController alloc] init] autorelease];
    self.webController.view.frame = self.view.bounds;
    self.webController.view.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.webView = self.webController.webView;
    [self.view addSubview:self.webController.webView];

	// Setup the bar button items
	
	[self setButtonItemWithImage:[UIImage imageNamed:@"CKWebViewControllerGoBack"] type:CKWebViewControllerButtonItemBack target:nil action:nil];
	[self setButtonItemWithImage:[UIImage imageNamed:@"CKWebViewControllerGoForward"] type:CKWebViewControllerButtonItemForward target:nil action:nil];
	[self setButtonItemWithSystemItem:UIBarButtonSystemItemRefresh type:CKWebViewControllerButtonItemRefresh target:nil action:nil];
	
	UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	[activityView startAnimating];
	self.spinnerItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
    self.spinnerItem.name = @"spinnerItem";
	self.spinnerItem.tag = CKWebViewControllerButtonItemRefresh;
}

- (void)viewWillAppear:(BOOL)animated {
    CKViewControllerAnimatedBlock oldViewWillAppearEndBlock = [self.viewWillAppearEndBlock copy];
    self.viewWillAppearEndBlock = nil;
    
	[super viewWillAppear:animated];
    
    [self.webController viewWillAppear:animated];
    self.webController.delegate = self;
    
    self.wasUsingToolbar = !self.navigationController.toolbarHidden;
    self.wasUsingNavigationbar = !self.navigationController.navigationBarHidden;
    
    [self.webController loadURL:self.homeURL];
    
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
	
	[self setToolbarItems:items animated:NO];
    
    if(self.autoManageNavigationAndToolBar){
        [self.navigationController setNavigationBarHidden:NO animated:animated];
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
    
    if(oldViewWillAppearEndBlock){
        oldViewWillAppearEndBlock(self,animated);
    }
    self.viewWillAppearEndBlock = oldViewWillAppearEndBlock;
}

- (void)setHomeURL:(NSURL *)thehomeURL{
    [_homeURL release];
    _homeURL = [thehomeURL retain];
    
    if(self.isViewDisplayed){
        [self.webController loadURL:self.homeURL];
        
        self.backButtonItem.enabled = NO;
        self.forwardButtonItem.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    [self.webController viewDidAppear:animated];
	self.webController.delegate = nil;
    
    if(self.autoManageNavigationAndToolBar){
        [self.navigationController setToolbarHidden:!self.wasUsingToolbar animated:animated];
        [self.navigationController setNavigationBarHidden:!self.wasUsingNavigationbar animated:animated];
    }
}

- (void)viewDidUnload {
	self.backButtonItem = nil;
	self.forwardButtonItem = nil;
	self.refreshButtonItem = nil;
	self.actionButtonItem = nil;
	self.spinnerItem = nil;
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Public API

- (NSURL *)currentURL {
	return self.webController.currentURL;
}

- (void)setButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action {
	UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:target action:action] autorelease];
	[self setBarButtonItem:item forItemType:type target:target action:action];
}

- (void)setButtonItemWithImage:(UIImage *)image type:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action {
	//if (image == nil)
	//	return;
	UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action] autorelease];
	[self setBarButtonItem:item forItemType:type target:target action:action];
}

#pragma mark Toolbar Management

- (void)setBarButtonItem:(UIBarButtonItem *)buttonItem forItemType:(CKWebViewControllerButtonItemType)type target:(id)target action:(SEL)action {
	
	if (target) buttonItem.target = target;
	if (action) buttonItem.action = action;
	
	switch (type) {
		case CKWebViewControllerButtonItemBack:
			self.backButtonItem = buttonItem;
            self.backButtonItem.name = @"backButtonItem";
			self.backButtonItem.target = self;
			self.backButtonItem.action = @selector(actionGoBack);
			self.backButtonItem.enabled = NO;
			break;
		case CKWebViewControllerButtonItemForward:
			self.forwardButtonItem = buttonItem;
            self.forwardButtonItem.name = @"forwardButtonItem";
			self.forwardButtonItem.target = self;
			self.forwardButtonItem.action = @selector(actionGoForward);
			self.forwardButtonItem.enabled = NO;
			break;
		case CKWebViewControllerButtonItemRefresh:
			self.refreshButtonItem = buttonItem;
            self.refreshButtonItem.name = @"refreshButtonItem";
			self.refreshButtonItem.target = self;
			self.refreshButtonItem.action = @selector(actionRefresh);
			self.refreshButtonItem.enabled = YES;
			break;
		case CKWebViewControllerButtonItemAction:
			self.actionButtonItem = buttonItem;
            self.actionButtonItem.name = @"actionButtonItem";
			self.actionButtonItem.enabled = YES;
		default:
			break;
	}
	buttonItem.tag = type;	
}

- (void)actionGoBack {
	[self.webController.webView goBack];
    
	self.backButtonItem.enabled = self.webController.webView.canGoBack;
	self.forwardButtonItem.enabled = self.webController.webView.canGoForward;	
}
- (void)actionGoForward {
	[self.webController.webView goForward];
    
	self.backButtonItem.enabled = self.webController.webView.canGoBack;
	self.forwardButtonItem.enabled = self.webController.webView.canGoForward;	
}
- (void)actionRefresh {
	[self.webController.webView reload];
}

#pragma mark WebView Delegate

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem *)item inToolbar:(UIToolbar*)toolbar{
	NSInteger i = 0;
	for (UIBarButtonItem *button in toolbar.items) {
		if (button.tag == tag) {
			NSMutableArray *theItems = [NSMutableArray arrayWithArray:toolbar.items];
			[theItems replaceObjectAtIndex:i withObject:item];
			toolbar.items = theItems;
			break;
		}
		i++;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self replaceItemWithTag:CKWebViewControllerButtonItemRefresh withItem:self.spinnerItem inToolbar:self.navigationController.toolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	// Update the title
	if (self.showDocumentTitle) {
		self.title = [self.webController.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	}
    
	[self replaceItemWithTag:CKWebViewControllerButtonItemRefresh withItem:self.refreshButtonItem inToolbar:self.navigationController.toolbar];
	
	self.backButtonItem.enabled = self.webController.webView.canGoBack;
	self.forwardButtonItem.enabled = self.webController.webView.canGoForward;	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
