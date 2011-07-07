//
//  CKWebService.m
//  CloudKit
//
//  Created by Fred Brunel on 09-11-10.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebService.h"
#import "ASIHTTPRequest.h"
#import "Reachability.h"
#import "CKLocalization.h"
#import "CKAlertView.h"

static NSString * const CKUBWebServiceAlertTypeNetworkReachability = @"CKWebServiceAlertTypeNetworkReachability";

//

@interface CKWebService ()

@property (nonatomic, retain, readwrite) Reachability *reachability;
@property (nonatomic, retain, readwrite) NSString *username;
@property (nonatomic, retain, readwrite) NSString *password;
@property (nonatomic, retain, readwrite) NSMutableDictionary *defaultParams;
@property (nonatomic, retain, readwrite) NSMutableDictionary *defaultHeaders;

- (BOOL)checkReachabilityWithAlert:(BOOL)showAlert withUserObject:(id)object;

@end

//

@implementation CKWebService

@synthesize reachability = _reachability;
@synthesize baseURL = _baseURL;
@synthesize defaultParams = _defaultParams;
@synthesize defaultHeaders = _defaultHeaders;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark Initialization

- (id)init {
	if (self = [super init]) {
		self.defaultParams = [NSMutableDictionary dictionary];
		self.defaultHeaders = [NSMutableDictionary dictionary];
		self.reachability = [Reachability reachabilityForInternetConnection];
		[self.reachability startNotifer];
	}
	return self;
}

- (void)dealloc {
	[self.reachability stopNotifer];
	self.reachability = nil;	
	self.baseURL = nil;
	self.defaultParams = nil;
	self.defaultHeaders = nil;
	self.username = nil;
	self.password = nil;
	[super dealloc];
}

#pragma mark Properties

- (void)setDefaultBasicAuthWithUsername:(NSString *)username password:(NSString *)password {
	self.username = username;
	self.password = password;
}

#pragma mark Create Requests

- (id)performRequest:(CKWebRequest *)request {
	[request setHeaders:self.defaultHeaders];
	
	if ([self checkReachabilityWithAlert:YES withUserObject:request] == NO) 
		return request;
	
	// TODO: put the request in a different queue than the shared queue (default)	
	// ASIHTTPRequest *httpRequest = [request performSelector:@selector(connect)];
	// [httpRequest start];
	[request start];
	return request;
}

#pragma mark Request Facade

- (id)getRequestForPath:(NSString *)path params:(NSDictionary *)params {
	// TODO: We should check the validity of the URL somewhere, maybe in CKWebRequest
	NSString *theURL = self.baseURL ? [[self.baseURL absoluteString] stringByAppendingString:path] : path;
	
	NSDictionary *theParams = nil;
	if (self.defaultParams) {
		NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.defaultParams];
		[dic addEntriesFromDictionary:params];
		theParams = dic;
	} else {
		theParams = params;
	}
	
	CKWebRequest *request = [CKWebRequest requestWithURLString:theURL params:theParams];
	[request setBasicAuthWithUsername:self.username password:self.password];
	
	return request;
}

- (id)getPath:(NSString *)path params:(NSDictionary *)params delegate:(id)delegate {
	CKWebRequest *request = [self getRequestForPath:path params:params];
	[request setDelegate:delegate];
	return [self performRequest:request];
}

#pragma mark Reachability

- (BOOL)checkReachabilityWithAlert:(BOOL)showAlert withUserObject:(id)object {
    NetworkStatus netStatus = [_reachability currentReachabilityStatus];
    if (netStatus == NotReachable) {
		if (showAlert) {
			CKAlertView *alertView = [[[CKAlertView alloc] initWithTitle:_(@"No Internet Connection") message:_(@"No Internet Message")] autorelease];
			[alertView addButtonWithTitle:_(@"Dismiss") action:nil];
			[alertView addButtonWithTitle:_(@"Retry") action:^(void) {
				CKWebRequest *request = (CKWebRequest *)(object);
				if (request) [self performRequest:request];
			}];
			[alertView show];
		}
		return NO;
	}
	return YES;
}

@end