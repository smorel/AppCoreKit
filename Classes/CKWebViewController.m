//
//  CKWebViewController.m
//  YellowPages
//
//  Created by Olivier Collet on 10-02-03.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKWebViewController.h"
#import "CKUIViewAutoresizing+Additions.h"
#import "CKBundle.h"
#import <VendorsKit/Reachability.h>

#define CKBarButtonItemFlexibleSpace [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]

@interface CKWebViewController () <UIWebViewDelegate>

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, copy) void (^completionBlock)(UIWebView *webView, NSError *error);

@property (nonatomic, retain) Reachability *reachability;

@end

@implementation CKWebViewController

@synthesize URL, webView, completionBlock, reachability;

- (void)dealloc {
    [super dealloc];
    
    self.URL = nil;
    self.webView = nil;
    self.completionBlock = nil;
    self.reachability = nil;
}

- (NSURL *)currentURL {
	return [[NSURL URLWithString:[self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"]] standardizedURL];
}

- (void)loadURL:(NSURL *)anURL withCompletionBlock:(void (^)(UIWebView *webView, NSError *error))completion {
    self.completionBlock = completion;
    
    self.URL = anURL;
    [self loadCurrentURL];
}

#pragma mark - LifeCycle

- (void)loadView {
    [super loadView];
    
    self.webView = [[[UIWebView alloc] initWithFrame:self.view.frame] autorelease];
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
    
    [self.reachability startNotifer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.reachability stopNotifer];    
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
    if (reachability == nil) {
        self.reachability = [Reachability reachabilityForInternetConnection];
    }
    return reachability;
}

#pragma mark -
#pragma mark WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([request.URL isEqual:[NSURL URLWithString:@"about:blank"]] && navigationType == UIWebViewNavigationTypeReload) return NO;
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	
	// Change the size of the popover according to the size of the body
	CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
	if (height > 0)
		self.contentSizeForViewInPopover = CGSizeMake(self.contentSizeForViewInPopover.width, height);
    
    if (self.completionBlock)
        completionBlock(self.webView, nil);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.completionBlock)
        completionBlock(self.webView, error);
}

@end
