//
//  CKWebRequest.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNSString+URIQuery.h"
#import "CKWebRequest.h"
#import "CKWebRequestManager.h"
#import "CKWebDataConverter.h"

NSString * const CKWebRequestHTTPErrorDomain = @"CKWebRequestHTTPErrorDomain";

@interface CKWebRequest () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLResponse *response;

@property (nonatomic, retain) NSMutableData *data;

@end

@implementation CKWebRequest

@synthesize connection, request, response;
@synthesize data, completionBlock;
@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        self.data = [NSMutableData data];
    }
    return self;
}

- (id)initWithCompletion:(void (^)(id, NSURLResponse *, NSError *))block {
    if (self = [self init]) {
        self.completionBlock = block;
    }
    return block;
}

- (id)initWithURL:(NSURL *)url completion:(void (^)(id, NSURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[NSURLRequest alloc] initWithURL:url];
    return [self initWithURLRequest:aRequest completion:block];
}

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(void (^)(id, NSURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[NSURLRequest alloc] initWithURL:url];
    return [self initWithURLRequest:aRequest parameters:parameters completion:block];
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest completion:(void (^)(id, NSURLResponse *, NSError *))block {
    return [self initWithURLRequest:aRequest parameters:nil completion:block];
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest parameters:(NSDictionary *)parameters completion:(void (^)(id, NSURLResponse *, NSError *))block {
    if (self = [super init]) {
        NSMutableURLRequest *mutableRequest = aRequest.mutableCopy;
        if (parameters) {
            NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", aRequest.URL.absoluteString, [NSString stringWithQueryDictionary:parameters]]];
            [mutableRequest setURL:newURL];
        }
        
        self.request = mutableRequest;
        self.completionBlock = block;
    }
    return self;
}

#pragma mark - Convinience methods

+ (NSCachedURLResponse *)cachedResponseForURL:(NSURL *)anURL {
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:anURL];
	return [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
}

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url completion:(void (^)(id, NSURLResponse *, NSError *))block {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    return [self scheduledRequestWithURLRequest:request completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(void (^)(id, NSURLResponse *, NSError *))block {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    return [self scheduledRequestWithURLRequest:request parameters:parameters completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request completion:(void (^)(id, NSURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return webRequest;
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters completion:(void (^)(id, NSURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request parameters:parameters completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return webRequest;
}

#pragma mark - LifeCycle

- (void)start {
    [self startOnRunLoop:[NSRunLoop currentRunLoop]];
}

- (void)startOnRunLoop:(NSRunLoop *)runLoop {
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO] autorelease];
    self.data = [[[NSMutableData alloc] init] autorelease];
    
    [self.connection scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse {
    self.response = aResponse;
    
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
        [self.delegate connection:aConnection didReceiveResponse:aResponse];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)someData {
    [self.data appendData:someData];
    
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveData:)]) 
        [self.delegate connection:aConnection didReceiveData:someData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    id object = [CKWebDataConverter convertData:self.data fromResponse:self.response];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.completionBlock(object, self.response, nil);
    });
    
    if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
        [self.delegate connectionDidFinishLoading:aConnection];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.completionBlock(nil, self.response, error);
    });
    
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)])
        [self.delegate connection:aConnection didFailWithError:error];
}

#pragma mark - Getters

- (NSURL *)URL {
    return self.request.URL;
}

@end
