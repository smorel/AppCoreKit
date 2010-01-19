//
//  YPWebService.m
//  YellowPages
//
//  Created by Fred Brunel on 09-11-10.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebService.h"

#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "CXMLDocument.h"
#import "RegexKitLite.h"
#import "CKDebug.h"

#define CKWebRequestKey @"CKWebRequestKey"

//

@implementation CKWebService

@synthesize username = _username;
@synthesize password = _password;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

#pragma mark Create Requests

- (CKWebRequest *)performRequest:(CKWebRequest *)request {
	ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:request.url];
	
	if (self.username && self.password) {
		[httpRequest setUsername:self.username];
		[httpRequest setPassword:self.password];
	}
	
	[httpRequest setDelegate:self];
	[httpRequest setUserInfo:[NSDictionary dictionaryWithObject:request forKey:CKWebRequestKey]];
	[httpRequest startAsynchronous];
	return request;
}

#pragma mark ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)httpRequest {
	CKWebRequest *request = [[httpRequest userInfo] objectForKey:CKWebRequestKey];
	
	// TODO: Trigger the "error" delegate when the status code > 400
	
	//NSInteger responseStatusCode = [httpRequest responseStatusCode];
	//NSString *responseStatusMessage = [httpRequest responseStatusMessage];
		
	// TODO: process the response according to the Content-Type (e.g., XML, JSON).
	
	NSError *error = nil;
	id responseContent;

	NSDictionary *responseHeaders = [httpRequest responseHeaders];
	if ([[responseHeaders objectForKey:@"Content-Type"] isMatchedByRegex:@"application/xml"]) {
		responseContent = [[CXMLDocument alloc] initWithData:[httpRequest responseData] options:0 error:nil];
	} else if ([[responseHeaders objectForKey:@"Content-Type"] isMatchedByRegex:@"application/json"]) {
		responseContent = [[CJSONDeserializer deserializer] deserialize:[httpRequest responseData] error:&error];
	} else {
		responseContent = [httpRequest responseString];
	}

	// Process the content
	
	id content = responseContent;
	
	if (request.transformer) {
		content = [request.transformer request:request transformContent:responseContent];
	}

	CKDebugLog(@"Response Content %@", content);	
	
	// Notifies the delegate
	
	if (error && [request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[request.delegate request:request didFailWithError:error];
		return;
	}
	
	if ([request.delegate respondsToSelector:@selector(request:didReceiveContent:)]) {
		[request.delegate request:request didReceiveContent:content];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)httpRequest {
	CKWebRequest *request = [[httpRequest userInfo] objectForKey:httpRequest];	
	if ([request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[request.delegate request:request didFailWithError:[httpRequest error]];
	}
}

@end