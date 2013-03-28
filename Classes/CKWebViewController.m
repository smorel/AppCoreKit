//
//  CKWebViewController.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKWebViewController.h"
#import "UIView+AutoresizingMasks.h"
#import <VendorsKit/Reachability.h>

#define CKBarButtonItemFlexibleSpace [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]

Reachability* CKWebViewControllerReachability = nil;

@interface CKWebViewController () <UIWebViewDelegate>

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) UIWebView *webView;

@end

@implementation CKWebViewController

@synthesize URL, webView, webViewDidFinishLoadingBlock;
@synthesize delegate;

- (void)dealloc {    
    self.URL = nil;
    self.webView = nil;
    self.webViewDidFinishLoadingBlock = nil;
    self.webView.delegate = nil;
    
    [super dealloc];
}

- (NSURL *)currentURL {
	return [[NSURL URLWithString:[self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"]] standardizedURL];
}

- (id)initWithURL:(NSURL *)anURL {
    return [self initWithURL:anURL webViewDidFinishLoadingBlock:nil];
}

- (id)initWithURL:(NSURL *)anURL webViewDidFinishLoadingBlock:(void (^)(UIWebView *, NSError *))completion {
    if (self = [super init]) {
        self.URL = anURL;
        self.webViewDidFinishLoadingBlock = completion;
    }
    return self;
}

- (void)loadURL:(NSURL *)anURL {
    self.URL = anURL;
    [self loadCurrentURL];
}

#pragma mark - LifeCycle

- (void)loadView {
    [super loadView];
    
    self.webView = [[[UIWebView alloc] initWithFrame:self.view.frame] autorelease];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
    self.webView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadCurrentURL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (BOOL)loadCurrentURL {
    if (self.URL && self.webView) {
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:self.URL] autorelease];
        [self.webView loadRequest:request];
        return YES;
    }
    return NO;
}

- (void)reachabilityChanged:(NSNotification*)notif {
    if (self.reachability.currentReachabilityStatus != NotReachable) {
        [self loadCurrentURL];
    }
}

- (Reachability *)reachability {
    if (CKWebViewControllerReachability == nil) {
        CKWebViewControllerReachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifer];
    }
    return CKWebViewControllerReachability;
}

#pragma mark -
#pragma mark WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        return [self.delegate webView:self.webView shouldStartLoadWithRequest:request navigationType:navigationType];
    else
        return !([request.URL isEqual:[NSURL URLWithString:@"about:blank"]] && navigationType == UIWebViewNavigationTypeReload);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [self.delegate webViewDidStartLoad:self.webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {	
	// Change the size of the popover according to the size of the body
	CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
	if (height > 0)
		self.contentSizeForViewInPopover = CGSizeMake(self.contentSizeForViewInPopover.width, height);
    
    if (self.webViewDidFinishLoadingBlock)
        webViewDidFinishLoadingBlock(self.webView, nil);
    
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [self.delegate webViewDidFinishLoad:self.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.webViewDidFinishLoadingBlock)
        webViewDidFinishLoadingBlock(self.webView, error);
    
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [self.delegate webView:self.webView didFailLoadWithError:error];
}

@end
