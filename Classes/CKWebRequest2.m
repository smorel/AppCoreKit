//
//  CKWebRequest2.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKWebRequest2.h"
#import "CKNSStringAdditions.h"
#import "CKNSObject+Invocation.h"
#import "CJSONDeserializer.h"
#import "CXMLDocument.h"
#import "RegexKitLite.h"
#import "CKDebug.h"

//

static NSUInteger theNumberOfRequestRunning = 0;
static NSOperationQueue *theSharedQueue = nil;

//

NSString * const CKWebRequestHTTPErrorDomain = @"CKWebRequestHTTPErrorDomain";

@interface CKWebRequest2 ()
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;

- (void)markAsExecuting;
- (void)markAsFinished;
- (void)markAsCancelled;

@end

//

@implementation CKWebRequest2

@synthesize URL = theURL;
@synthesize connection = theConnection;
@synthesize receivedData = theReceivedData;
@synthesize response = theResponse;
@synthesize userInfo = theUserInfo;
@synthesize delegate = theDelegate;

#pragma mark Initialization

+ (NSURLRequest *)defaultURLRequestForURL:(NSURL*)anURL{
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:anURL
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:60.0];
	[request addValue:[CKWebRequest2 defaultUserAgentString] forHTTPHeaderField:@"User-Agent"];
	return [request autorelease];
}

+ (void)initialize {
	if (self == [CKWebRequest2 class]) {
		theSharedQueue = [[NSOperationQueue alloc] init];
		[theSharedQueue setName:@"CKWebRequest"];
		[theSharedQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
}

- (id)initWithURL:(NSURL *)anURL {
	if (self = [super init]) {
		theRequest = [[CKWebRequest2 defaultURLRequestForURL:anURL] retain];
	}
	return self;
}

- (void)dealloc {
	theDelegate = nil;
	[theRequest release];
	[theReceivedData release];
	[theResponse release];
	[theUserInfo release];
	[theConnection release];
	[super dealloc];
}

+ (NSString *)defaultUserAgentString {
	static NSString *userAgent = nil;
	if (userAgent == nil) {
		NSBundle *bundle = [NSBundle mainBundle];
		UIDevice *device = [UIDevice currentDevice];
		NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"]; 
		NSString *versionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *buildNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
		NSString *appVersion = [NSString stringWithFormat:@"%@-%@", versionNumber, buildNumber];
		NSString *model = [device model];
		NSString *systemName = [device systemName];
		NSString *systemVersion = [device systemVersion];
		NSString *locale = [[NSLocale currentLocale] localeIdentifier]; // FIXME: this is the current locale of the application localization, not the system.
		userAgent = [[NSString stringWithFormat:@"%@/%@ (%@; %@; %@)", appName, appVersion, model, systemName, systemVersion, locale] retain];
	}
	return userAgent;
}

#pragma mark Public API

- (NSURL *)URL {
	return theRequest.URL;
}

- (NSDictionary *)headers {
	return [theRequest allHTTPHeaderFields];
}

- (void)setHeaders:(NSDictionary *)headers {
	NSMutableDictionary *fields = [[[theRequest allHTTPHeaderFields] mutableCopy] autorelease];
	[fields addEntriesFromDictionary:headers];	
	[theRequest setAllHTTPHeaderFields:fields];
}

- (void)setMethod:(NSString *)method {
	[theRequest setHTTPMethod:method];
}

- (void)setBodyData:(NSData *)bodyData {
	[theRequest setHTTPBody:bodyData];
	[theRequest setValue:[NSString stringWithFormat:@"%llu", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
}

//

+ (CKWebRequest2 *)requestWithURL:(NSURL *)URL {
	return [[[CKWebRequest2 alloc] initWithURL:URL] autorelease];
}

+ (CKWebRequest2 *)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params {
	NSURL *URL = [NSURL URLWithString:(params ? [NSString stringWithFormat:@"%@?%@", URLString, [NSString stringWithQueryDictionary:params]] : URLString)];
	return [[[CKWebRequest2 alloc] initWithURL:URL] autorelease];
}

+ (CKWebRequest2 *)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate {
	CKWebRequest2 *request = [CKWebRequest2 requestWithURLString:URLString params:params];
	request.delegate = delegate;
	return request;
}

+ (CKWebRequest2 *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate {
	CKWebRequest2 *request = [CKWebRequest2 requestWithURLString:URLString params:params delegate:delegate];
	[request setMethod:method];
	return request;
}

+ (NSCachedURLResponse *)cachedResponseForURL:(NSURL *)anURL {
	NSURLRequest *request = [CKWebRequest2 defaultURLRequestForURL:anURL];
	return [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
}

//

- (void)start {
	NSAssert([[theRequest.URL scheme] isMatchedByRegex:@"^(http|https)$"], @"CKWebRequest supports only http and https requests.");
	
	if ([self isCancelled] || [self isExecuting] || [self isFinished])
		return;
	
	// If the request was started in the main thrad, start it in 
	// the shared queue instead.
	if ([NSThread isMainThread]) {
		[theSharedQueue addOperation:self];
		return;
	}
	
	[self markAsExecuting];

	NSMutableData *data = [[NSMutableData alloc] init];	
	self.receivedData = data;
	[data release];
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
	self.connection = conn;
	[conn release];
	
	[self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[self.connection start];
}

- (void)cancel {
	[theConnection cancel];
	[self markAsCancelled];
}

#pragma mark URL Loading

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
//	CKDebugLog(@"willCacheResponse: %@ (%d bytes)", cachedResponse, [[cachedResponse data] length]);
	return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//	CKDebugLog(@"didReceiveResponse %@", response);
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [theReceivedData setLength:0];
	self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//CKDebugLog(@"didReceiveData (%d bytes)", [data length]);
	
	// Append the new available data
	// TODO: provide an delegate to notify for the progress of the URL loading
    [theReceivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	return;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//	CKDebugLog(@"didFinishLoading <%@>", theRequest.URL);
	
	if ([theResponse statusCode] > 400) {
		NSString *stringForStatusCode = [NSHTTPURLResponse localizedStringForStatusCode:[theResponse statusCode]];
		NSError *error = [NSError errorWithDomain:CKWebRequestHTTPErrorDomain
											 code:[theResponse statusCode]
										 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:stringForStatusCode, NSLocalizedDescriptionKey, nil]];

		[theDelegate performSelectorOnMainThread:@selector(request:didFailWithError:) 
									  withObject:self 
									  withObject:error 
								   waitUntilDone:NO];

		[self markAsFinished];
		return;
	}
	
	// Notifies the delegate data has been received with the HTTP headers
	
	[theDelegate performSelectorOnMainThread:@selector(request:didReceiveData:withResponseHeaders:) 
								  withObject:self 
								  withObject:theReceivedData
								  withObject:[theResponse allHeaderFields]
							   waitUntilDone:NO];
	
	// Try to process the response according to the Content-Type (e.g., XML, JSON).
	// FIXME: The processing should happen in a different class (a default transformer).
	
	id responseValue;
	NSDictionary *responseHeaders = [theResponse allHeaderFields];
	NSError *error = nil;
	NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];
	
	if ([contentType isMatchedByRegex:@"(application|text)/xml"]) {
		responseValue = [[[CXMLDocument alloc] initWithData:theReceivedData options:0 error:nil] autorelease];
	} else if ([contentType isMatchedByRegex:@"application/json"]) {
		responseValue = [[CJSONDeserializer deserializer] deserialize:theReceivedData error:&error];
	} else if ([contentType isMatchedByRegex:@"image/"]) {
		responseValue = [UIImage imageWithData:theReceivedData];
	} else if ([contentType isMatchedByRegex:@"text/"]) {
		// TODO: Check for the encoding
		responseValue = [[[NSString alloc] initWithData:theReceivedData encoding:NSASCIIStringEncoding] autorelease];
	} else {
		responseValue = [[theReceivedData copy] autorelease];
	}
	
	// Notifies the delegate if a parsing error has occured
	
	if (error) {
		[theDelegate performSelectorOnMainThread:@selector(request:didFailWithError:) withObject:self withObject:error waitUntilDone:NO];
		[self markAsFinished];
		return;
	}
	
	// Process the content wih the user specified CKWebResponseTransformer
	
//	id value = responseValue;
//	if (_transformer) {
//		value = [_transformer request:self transformContent:responseValue];
//	}
	
	// Notifies the delegate of the final value; finish the process.

	[theDelegate performSelectorOnMainThread:@selector(request:didReceiveValue:) 
								  withObject:self 
								  withObject:responseValue 
							   waitUntilDone:NO];	
	
	[self markAsFinished];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	CKDebugLog(@"ERR Connection failed! %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	[theDelegate performSelectorOnMainThread:@selector(request:didFailWithError:) withObject:self withObject:error waitUntilDone:NO];
	[self markAsFinished];
}

#pragma mark NSOperation

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return executing;
}

- (BOOL)isFinished {
	return finished;
}

- (void)markAsExecuting {
	if (executing) return;
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
	
	theNumberOfRequestRunning++;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)markAsCancelled {
	[self willChangeValueForKey:@"isCancelled"];
	cancelled = YES;
	[self didChangeValueForKey:@"isCancelled"];
	[self markAsFinished];
}

- (void)markAsFinished {
	if (finished) return;
	
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"isExecuting"];
	executing = NO;
    finished = YES;
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
	
	theNumberOfRequestRunning--;
	if (theNumberOfRequestRunning == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

@end
