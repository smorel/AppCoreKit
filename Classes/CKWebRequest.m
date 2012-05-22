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
@property (nonatomic, retain) NSFileHandle *handle;
@property (nonatomic, retain, readwrite) NSString *downloadPath;

@property (nonatomic, assign, readwrite) CGFloat progress;
@property (nonatomic, assign) NSUInteger retriesCount;

@end

@implementation CKWebRequest

@synthesize connection, request, response;
@synthesize data, completionBlock, transformBlock, handle, downloadPath;
@synthesize delegate, progress, retriesCount;

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

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[NSURLRequest alloc] initWithURL:url];
    return [self initWithURLRequest:aRequest parameters:parameters downloadAtPath:path completion:block];
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
        self.data = [[[NSMutableData alloc] init] autorelease];
    }
    return self;
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSURLResponse *, NSError *))block {
    if (self = [self initWithURLRequest:aRequest parameters:parameters completion:block]) {
        self.handle = [NSFileHandle fileHandleForWritingAtPath:path];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            unsigned long long existingDataLenght = [attributes fileSize];
            NSString* bytesStr = [NSString stringWithFormat:@"bytes=%qu-", existingDataLenght];
            
            NSMutableURLRequest *mutableRequest = self.request.mutableCopy;
            [mutableRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
            self.request = mutableRequest;
            
            [self.handle seekToFileOffset:existingDataLenght];
        }
        
        self.downloadPath = path;
        self.retriesCount = 0;
    }
    return nil;
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

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSURLResponse *, NSError *))block {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    return [self scheduledRequestWithURLRequest:request parameters:parameters downloadAtPath:path completion:block];
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

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request parameters:parameters downloadAtPath:path completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return webRequest;
}

#pragma mark - LifeCycle

- (void)start {
    [self startOnRunLoop:[NSRunLoop currentRunLoop]];
}

- (void)startOnRunLoop:(NSRunLoop *)runLoop {
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO] autorelease];
    self.progress = 0.0;
    
    [self.connection scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSHTTPURLResponse *)aResponse {
    self.response = aResponse;
    
    if ([aResponse statusCode] >= 400)
        self.handle = nil;
    
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
        [self.delegate connection:aConnection didReceiveResponse:aResponse];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)someData {
    if (self.handle) {
        self.progress = self.handle.offsetInFile / self.response.expectedContentLength;
        [self.handle writeData:someData];
    }
    else {
        self.progress = self.data.length / self.response.expectedContentLength;
        [self.data appendData:someData];
    }
    
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveData:)]) 
        [self.delegate connection:aConnection didReceiveData:someData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    self.progress = 1.0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id object = [CKWebDataConverter convertData:self.data fromResponse:self.response];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (self.completionBlock)
                self.completionBlock(object, self.response, nil);
            
            if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
                [self.delegate connectionDidFinishLoading:aConnection];
        });
    });
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    if (!([error code] == NSURLErrorTimedOut && [self retry] && self.handle)) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (self.completionBlock)
                self.completionBlock(nil, self.response, error);
        });
        
        if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)])
            [self.delegate connection:aConnection didFailWithError:error];
    }
}

#pragma mark - Getters

- (BOOL)retry {
    if (self.retriesCount++ == 3)
        return NO;
    else {
      	[self cancel];
        [self start];
        return YES;  
    }
}

- (NSURL *)URL {
    return self.request.URL;
}

@end
