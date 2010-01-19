//
//  CKWebRequest.m
//  CloudKit
//
//  Created by Fred Brunel on 09-11-09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebRequest.h"
#import "CKNSStringAdditions.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "CXMLDocument.h"
#import "RegexKitLite.h"
#import "CKDebug.h"

@implementation CKWebRequest

@synthesize delegate = _delegate;
@synthesize transformer = _transformer;
@synthesize userInfo = _userInfo;
@synthesize url = _url;
@synthesize timestamp = _timestamp;

- (id)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		_delegate = nil;
		_transformer = nil;
		_userInfo = nil;
		_httpRequest = nil;
		_url = [url retain];
		_timestamp = nil;		
	}
	return self;
}

- (void)dealloc {
	[_userInfo release];
	[_url release];
	[_timestamp release];
	[_httpRequest cancel];
	[_httpRequest release];
	[super dealloc];
}

//

+ (CKWebRequest *)requestWithURLString:(NSString *)url params:(NSDictionary *)params {
	NSURL *theURL = params ? [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url, [NSString stringWithQueryDictionary:params]]] : url;
	return [[[CKWebRequest alloc] initWithURL:theURL] autorelease];
}

//

- (void)cancel {
	if (_httpRequest) {
		[_httpRequest cancel];
		[_httpRequest release];
		_httpRequest = nil;
		
//		if ([_delegate respondsToSelector:@selector(requestWasCancelled:)]) {
//			[_delegate requestWasCancelled:self];
//		}
	}
}

// Connect the request (called by CKWebService)
// TODO: Username and password should be part of the CKWebService and queried here

- (void)connect:(NSString *)username password:(NSString *)password {
	_httpRequest = [[ASIHTTPRequest requestWithURL:self.url] retain];
	_httpRequest.username = username;
	_httpRequest.password = password;
	_httpRequest.delegate = self;
	_httpRequest.userInfo = [NSDictionary dictionaryWithObject:self forKey:@"CKWebRequestKey"];
	_timestamp = [[NSDate date] retain];
	[_httpRequest startAsynchronous];	
}

#pragma mark ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)httpRequest {
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
	
	if (_transformer) {
		content = [_transformer request:self transformContent:responseContent];
	}
	
	CKDebugLog(@"Response Content %@", content);	
	
	// Notifies the delegate
	
	if (error && [_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[_delegate request:self didFailWithError:error];
		return;
	}
	
	if ([_delegate respondsToSelector:@selector(request:didReceiveContent:)]) {
		[_delegate request:self didReceiveContent:content];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)httpRequest {
	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[_delegate request:self didFailWithError:[httpRequest error]];
	}
}

@end