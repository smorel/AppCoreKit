//
//  YPWebService.m
//  YellowPages
//
//  Created by Fred Brunel on 09-11-10.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebService.h"
#import "ASIHTTPRequest.h"

//

@interface CKWebService ()

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@end

//

@implementation CKWebService

@synthesize baseURL = _baseURL;
@synthesize defaultParams = _defaultParams;
@synthesize defaultHeaders = _defaultHeaders;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark Initialization

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc {
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
	// TODO put the request in a different queue than the shared queue (default)	
	//ASIHTTPRequest *httpRequest = [request performSelector:@selector(connect)];
	//[httpRequest start];
	[request start];
	return request;
}

#pragma mark Request Facade

- (id)getPath:(NSString *)path params:(NSDictionary *)params delegate:(id)delegate {
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
		
	CKWebRequest *request = [CKWebRequest requestWithURLString:theURL params:theParams delegate:delegate];
	[request setBasicAuthWithUsername:self.username password:self.password];
	[request setDelegate:delegate];
	
	return [self performRequest:request];
}

@end