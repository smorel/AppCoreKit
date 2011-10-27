//
//  CKWebRequest2.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKWebRequest2.h"
#import "CKNSStringAdditions.h"
#import "CKNSString+URIQuery.h"
#import "CKNSObject+Invocation.h"
#import "CKNSObject+JSON.h"
#import "CXMLDocument.h"
#import "RegexKitLite.h"
#import "CKDebug.h"
#import "CKNetworkActivityManager.h"
#import "CKNSError+Additions.h"

//

static NSUInteger theNumberOfRequestRunning = 0;
static NSOperationQueue *theSharedQueue = nil;

//

NSString * const CKWebRequestHTTPErrorDomain = @"CKWebRequestHTTPErrorDomain";

@interface CKWebRequest2 ()
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain, readwrite) NSString *destinationPath;
@property (nonatomic, assign, readwrite) BOOL allowDestinationOverwrite;
@property (nonatomic, retain, readwrite) NSOutputStream *destinationStream;

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
@synthesize destinationPath;
@synthesize allowDestinationOverwrite;
@synthesize destinationStream;
@synthesize transformBlock = theTransformBlock;
@synthesize successBlock = theSuccessBlock;
@synthesize failureBlock = theFailureBlock;
@synthesize completedBlock = theCompletedBlock;

@synthesize validatesSecureCertificates;
@synthesize credential = _credential;

#pragma mark Initialization

+ (NSMutableURLRequest *)defaultURLRequestForURL:(NSURL*)anURL{
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:anURL
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:60.0];
	[request addValue:[CKWebRequest2 defaultUserAgentString] forHTTPHeaderField:@"User-Agent"];
	return [request autorelease];
}

+ (void)initialize {
	if (self == [CKWebRequest2 class]) {
		theSharedQueue = [[NSOperationQueue alloc] init];
		//[theSharedQueue setName:@"CKWebRequest"]; Does not work on iOS 3.x
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
	[theTransformBlock release];
	[theSuccessBlock release];
	[theFailureBlock release];
	[theCompletedBlock release];
	self.destinationPath = nil;
	self.destinationStream = nil;
    [_credential release];
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


- (void)setDestination:(NSString *)path allowOverwrite:(BOOL)allowOverwrite{
	self.destinationPath = path;
	self.allowDestinationOverwrite = allowOverwrite;
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
	[theRequest setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
}

- (void)setBodyParams:(NSDictionary *)params {
	[self setBodyData:[[NSString stringWithQueryDictionary:params] dataUsingEncoding:NSUTF8StringEncoding]];
	[self setMethod:@"POST"];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
}

- (void)startAsynchronous {
	[theSharedQueue addOperation:self];
}

//

+ (id)requestWithURL:(NSURL *)URL {
	NSAssert(URL != nil && [[URL scheme] isMatchedByRegex:@"^(http|https)$"], @"CKWebRequest supports only http and https requests.");
	return [[[[self class] alloc] initWithURL:URL] autorelease];
}

+ (id)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params {
	NSURL *URL = [NSURL URLWithString:(params ? [NSString stringWithFormat:@"%@?%@", URLString, [NSString stringWithQueryDictionary:params]] : URLString)];
	if(URL != nil){
		return [[[[self class] alloc] initWithURL:URL] autorelease];
	}
	return nil;
}

+ (id)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate {
	CKWebRequest2 *request = [[self class] requestWithURLString:URLString params:params];
	request.delegate = delegate;
	return request;
}

+ (id)requestWithMethod:(NSString *)method URLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate {
	CKWebRequest2 *request = [[self class] requestWithURLString:URLString params:params delegate:delegate];
	[request setMethod:method];
	return request;
}

+ (NSCachedURLResponse *)cachedResponseForURL:(NSURL *)anURL {
	NSURLRequest *request = [CKWebRequest2 defaultURLRequestForURL:anURL];
	return [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
}

- (void)openFileStream{
	if(self.allowDestinationOverwrite){
		NSError* error;
		[[NSFileManager defaultManager] removeItemAtPath:self.destinationPath error:&error];
		//TODO : HANDLE ERROR
	}
	
	self.destinationStream = [[[NSOutputStream alloc] initToFileAtPath:self.destinationPath append:YES] autorelease];
	[self.destinationStream open];
}

#pragma mark NSOperation Methods

- (void)start {
	if([self isCancelled]){
		//NSLog(@"start but already cancelled <%p>",self);
		[self markAsFinished];
		return;
	}
	
	if ( [self isExecuting] || [self isFinished]){
		//NSLog(@"start aborted <%p>",self);
		return;
	}
	
	//NSLog(@"start request <%p>",self);
	
	self.destinationStream = nil;
	if(self.destinationPath){
		[self openFileStream];
	}
	
	[self markAsExecuting];

	NSMutableData *data = [[NSMutableData alloc] init];	
	self.receivedData = data;
	[data release];
	
	// NSURLConnection automatically supports the decompression of gzipped HTTP bodies.
	// As of iOS 3.2, NSURLRequest automatically accepts a gzipped encoding when issuing requests.
	// We force the encoding to ensure it's supported on previous iOS versions.
	[theRequest addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
	self.connection = conn;
	[conn release];
	
	[self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[self.connection start];
}

- (void)cancel {
	if(self.destinationStream){
		[self.destinationStream close];
	}
	[theConnection cancel];
	[self markAsCancelled];
}

#pragma mark Connection Authentication

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

    if (([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) && (validatesSecureCertificate == NO)) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            return;
    }
    
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *credential = _credential ? 
          _credential : [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:[challenge protectionSpace]];
        
        if (credential) {
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            return;
        }
    }
        
    [[challenge sender] cancelAuthenticationChallenge:challenge];
}

#pragma mark URL Loading

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
//	CKDebugLog(@"willCacheResponse: %@ (%d bytes)", cachedResponse, [[cachedResponse data] length]);
	return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//	CKDebugLog(@"didReceiveResponse %@", response);
//	NSURLCache *cache = [NSURLCache sharedURLCache];
//	CKDebugLog(@"Cache mem %d (%d), disk %d (%d)", [cache currentMemoryUsage], [cache memoryCapacity], [cache currentDiskUsage], [cache diskCapacity]);
	
	[theDelegate performSelectorOnMainThread:@selector(request:didReceiveResponse:) 
								  withObject:self 
								  withObject:response 
							   waitUntilDone:NO];
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [theReceivedData setLength:0];
	byteReceived = 0;
	
	self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//CKDebugLog(@"didReceiveData (%d bytes)", [data length]);
	
	long long expectedLength = [self.response expectedContentLength];
	NSAssert(expectedLength != 0,@"Expected length for request is 0.");
	byteReceived += [data length];
	float progress = (float)byteReceived / (float)expectedLength;
	
	[theDelegate performSelectorOnMainThread:@selector(request:didReceivePartialData:progress:) 
								  withObject:self 
								  withObject:data 
								  withObject:[NSNumber numberWithFloat:progress]
							   waitUntilDone:NO];
	
	if(self.destinationStream && ([theResponse statusCode] == 200 || [theResponse statusCode] == 206)){
		[self.destinationStream write:[data bytes] maxLength:[data length]];
	}
	else{
		// Append the new available data
		[theReceivedData appendData:data];
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	return;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//	CKDebugLog(@"didFinishLoading <%@>", theRequest.URL);
	
	// FIXME: This perform needs to be tested before called because its the one from the framework.
	// The other calls are implemented in CKNSObject+Invocation and test that the receiver responds to the
	// message
	
	if ([theDelegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
		[theDelegate performSelectorOnMainThread:@selector(requestDidFinishLoading:) 
									  withObject:self 
								   waitUntilDone:NO];
	}
	
	// Direct to disk
	
	if (self.destinationStream) {
		[self.destinationStream close];
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
	
	id responseValue = nil;
	NSDictionary *responseHeaders = [theResponse allHeaderFields];
	NSError *error = nil;
	NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];
    if(contentType == nil){
        contentType = [theResponse MIMEType];
    }
    CKDebugLog(@"Recv Content-Type: %@", contentType);
	
	if ([contentType isMatchedByRegex:@"(application|text)/xml"]) {
		responseValue = [[[CXMLDocument alloc] initWithData:theReceivedData options:0 error:nil] autorelease];
	} else if ([contentType isMatchedByRegex:@"application/json"]) {
		responseValue = [NSObject objectFromJSONData:theReceivedData error:&error];
	} else if ([contentType isMatchedByRegex:@"image/"]) {
		responseValue = [UIImage imageWithData:theReceivedData];
	} else if ([contentType isMatchedByRegex:@"text/"]) {
		// TODO: Check for the encoding
		responseValue = [[[NSString alloc] initWithData:theReceivedData encoding:NSASCIIStringEncoding] autorelease];
	} else {
		responseValue = [[theReceivedData copy] autorelease];
	}
    
    if ([theResponse statusCode] >= 400 || error) {
        //aggregate error !
		NSString *stringForStatusCode = [NSHTTPURLResponse localizedStringForStatusCode:[theResponse statusCode]];
		/*NSError *error2 = [NSError errorWithDomain:CKWebRequestHTTPErrorDomain
											 code:[theResponse statusCode]
										 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:stringForStatusCode, NSLocalizedDescriptionKey, nil]];*/
        error = aggregateError(error, CKWebRequestHTTPErrorDomain, [theResponse statusCode], stringForStatusCode);
        
		[theDelegate performSelectorOnMainThread:@selector(request:didFailWithError:) 
									  withObject:self 
									  withObject:error 
								   waitUntilDone:NO];
        
        if (theFailureBlock) {
            theFailureBlock(error);
        }
        
        if(theCompletedBlock){
            theCompletedBlock(responseValue,theResponse,error);
        }
        
		[self markAsFinished];
		return;
	}
	
	// Process the content wih the user specified CKWebResponseTransformer
	
	id value = responseValue;
	if (theTransformBlock) {
		value = theTransformBlock(responseValue);
	}
//	if (_transformer) {
//		value = [_transformer request:self transformContent:responseValue];
//	}
	
	// Notifies the delegate of the final value; finish the process.

	[theDelegate performSelectorOnMainThread:@selector(request:didReceiveValue:) 
								  withObject:self 
								  withObject:value 
							   waitUntilDone:NO];	
	if (theSuccessBlock) {
		theSuccessBlock(value);
	}
    
    
    if(theCompletedBlock){
        theCompletedBlock(value,theResponse,error);
    }
    
	[self markAsFinished];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//NSURLErrorFailingURLStringErrorKey incompatible os3
	//CKDebugLog(@"ERR Connection failed! %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	[theDelegate performSelectorOnMainThread:@selector(request:didFailWithError:) withObject:self withObject:error waitUntilDone:NO];
    if (theFailureBlock) {
		theFailureBlock(error);
	}
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

- (BOOL)isCancelled {
	return cancelled;
}

- (void)markAsExecuting {
	if (executing) return;
	
	//NSLog(@"executing request <%p>",self);
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
	
	theNumberOfRequestRunning++;
	[[CKNetworkActivityManager defaultManager]addNetworkActivityForObject:self];
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)markAsCancelled {
	if(cancelled)return;
	
	//NSLog(@"cancelling request <%p>",self);
	[self willChangeValueForKey:@"isCancelled"];
	cancelled = YES;
	[self didChangeValueForKey:@"isCancelled"];
	
	if(executing){
		[self markAsFinished];
	}
}

- (void)markAsFinished {
	if (finished) return;
	
	//NSLog(@"finishing request <%p>",self);
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"isExecuting"];
	executing = NO;
    finished = YES;
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
	
	theNumberOfRequestRunning--;
	[[CKNetworkActivityManager defaultManager]removeNetworkActivityForObject:self];
	
	/*if (theNumberOfRequestRunning == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}*/
}

- (NSString*)description{
	return [NSString stringWithFormat:@"CKWebRequest2 <%p> Url='%@' destinationPath='%@' allowOverwrite='%@'",self,self.URL,self.destinationPath,self.allowDestinationOverwrite ? @"YES" : @"NO"];
}

@end
