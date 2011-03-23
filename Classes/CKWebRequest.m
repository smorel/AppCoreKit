//
//  CKWebRequest.m
//  CloudKit
//
//  Created by Fred Brunel on 09-11-09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CKNSStringAdditions.h"
#import "CJSONDeserializer.h"
#import "CXMLDocument.h"
#import "RegexKitLite.h"

NSString* const CKWebRequestErrorDomain = @"CKWebRequestErrorDomain";

static ASINetworkQueue *_sharedQueue = nil;

#pragma mark Private Interface

@interface CKWebRequest ()

@property (nonatomic, assign) id valueTarget;
@property (nonatomic, retain) NSString *valueTargetKeyPath;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@end

@interface CKWebRequest (Private)
- (ASINetworkQueue *)sharedQueue;
- (ASIHTTPRequest *)connect;
@end

//

@implementation CKWebRequest

@synthesize delegate = _delegate;
@synthesize transformer = _transformer;
@synthesize valueTarget = _valueTarget;
@synthesize valueTargetKeyPath = _valueTargetKeyPath;
@synthesize userInfo = _userInfo;
@synthesize url = _url;
@synthesize username = _username;
@synthesize password = _password;
@synthesize headers = _headers;

#pragma mark Initialization

- (id)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		_delegate = nil;
		_transformer = nil;
		_valueTarget = nil;
		_valueTargetKeyPath = nil;
		_userInfo = nil;
		_httpRequest = nil;
		_url = [url retain];
		_username = nil;
		_password = nil;
	}
	return self;
}

- (void)dealloc {
	[_valueTargetKeyPath release];
	[_userInfo release];
	[_url release];
	[_username release];
	[_password release];
	
	_valueTargetKeyPath = nil;
	_userInfo = nil;
	_httpRequest = nil;
	_username = nil;
	_password = nil;
	_delegate = nil;
	
	[super dealloc];
}

#pragma mark Public API

+ (CKWebRequest *)requestWithURL:(NSURL *)url {
	return [[[CKWebRequest alloc] initWithURL:url] autorelease];
}

+ (CKWebRequest *)requestWithURLString:(NSString *)url params:(NSDictionary *)params {
	NSURL *theURL = [NSURL URLWithString:(params ? [NSString stringWithFormat:@"%@?%@", url, [NSString stringWithQueryDictionary:params]] : url)];
	return [[[CKWebRequest alloc] initWithURL:theURL] autorelease];
}

+ (CKWebRequest *)requestWithURLString:(NSString *)url params:(NSDictionary *)params delegate:(id)delegate {
	CKWebRequest *request = [CKWebRequest requestWithURLString:url params:params];
	request.delegate = delegate;
	return request;
}

- (id)setValueTarget:(id)target forKeyPath:(NSString *)keyPath {
	NSAssert(target && keyPath, @"Target and key path must not be NIL");
	self.valueTarget = target;
	self.valueTargetKeyPath = keyPath;
	return self;
}

- (void)setBasicAuthWithUsername:(NSString *)username password:(NSString *)password {
	self.username = username;
	self.password = password;
}

//

- (void)start {
	// Adds the configured ASIHTTPRequest to the (default) shared queue 
	// to start immediately.
	[[self sharedQueue] addOperation:[self connect]];
}

- (void)cancel {
	if (_httpRequest) {
		[_httpRequest cancel];
		_httpRequest = nil;
	}
}

#pragma mark Private

- (ASINetworkQueue *)sharedQueue {
	if (!_sharedQueue) {
		_sharedQueue = [[ASINetworkQueue queue] retain];
		[_sharedQueue setShowAccurateProgress:NO];
		[_sharedQueue setShouldCancelAllRequestsOnFailure:NO];
		[_sharedQueue setSuspended:NO];
		[_sharedQueue setMaxConcurrentOperationCount:4];
	}
	return _sharedQueue;
}

// Connect the request (called by CKWebService)
// TODO: Username and password should be part of the CKWebService and queried here

- (ASIHTTPRequest *)connect {
	
	// Create an ASIHTTPRequest and keep it as a *weak* reference in the CKWebRequest
	// and implement the following retain cycle,
	//
	// CKWebRequest > retained by > ASIHTTPRequest > retained by > ASINetworkQueue
	//
	// As soon as the queue is done by the request, objects will be released in the
	// inverse cascade.
	
	_httpRequest = [ASIHTTPRequest requestWithURL:self.url];
	_httpRequest.username = self.username;
	_httpRequest.password = self.password;
	_httpRequest.requestHeaders = [[self.headers mutableCopy] autorelease];
	_httpRequest.delegate = self;
	_httpRequest.userInfo = [NSDictionary dictionaryWithObject:self forKey:@"CKWebRequestKey"];
	
	return _httpRequest;
}

#pragma mark ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)httpRequest {
	_httpRequest = nil; // Remove the reference, since after this point the object will be deallocated
		
	if ([httpRequest responseStatusCode] > 400) {
		NSError *error = [NSError errorWithDomain:CKWebRequestErrorDomain
									code:[httpRequest responseStatusCode] 
								userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[httpRequest responseStatusMessage], NSLocalizedDescriptionKey, nil]];
		if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
			[_delegate request:self didFailWithError:error];
		}
		return;
	}
	
	// Notifies the delegate data has been received with the HTTP headers
	
	if ([_delegate respondsToSelector:@selector(request:didReceiveData:withResponseHeaders:)]) {
		[_delegate request:self didReceiveData:[httpRequest responseData] withResponseHeaders:[httpRequest responseHeaders]];
	}
	
	// Try to process the response according to the Content-Type (e.g., XML, JSON).
	// TODO: to be refactored
	
	id responseValue;
	NSDictionary *responseHeaders = [httpRequest responseHeaders];
	NSError *error = nil;
	NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];
	
	if ([contentType isMatchedByRegex:@"(application|text)/xml"]) {
		responseValue = [[[CXMLDocument alloc] initWithData:[httpRequest responseData] options:0 error:nil] autorelease];
	} else if ([contentType isMatchedByRegex:@"application/json"]) {
		responseValue = [[CJSONDeserializer deserializer] deserialize:[httpRequest responseData] error:&error];
	} else if ([contentType isMatchedByRegex:@"image/"]) {
		responseValue = [UIImage imageWithData:[httpRequest responseData]];
	} else {
		responseValue = [httpRequest responseString]; // FIXME: Risky! The content might not be a string!
	}
	
	// Notifies the delegate
	
	if (error && [_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[_delegate request:self didFailWithError:error];
		return;
	}
	
	// Process the content wih the user specified CKWebResponseTransformer
	
	id value = responseValue;
	if (_transformer) {
		value = [_transformer request:self transformContent:responseValue];
	}
	
	if ([_delegate respondsToSelector:@selector(request:didReceiveValue:)]) {
		[_delegate request:self didReceiveValue:value];
	}
	
	// Notifies the target
	
	if (_valueTarget) {
		[_valueTarget setValue:value forKeyPath:_valueTargetKeyPath];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)httpRequest {
	_httpRequest = nil;
	
	// Don't call the error delegate when the request has been cancelled.
	// The delegate may be gone at this point.
	if ([[httpRequest error] code] == ASIRequestCancelledErrorType) {
		return;
	}
	
	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[_delegate request:self didFailWithError:[httpRequest error]];
	}
}

@end