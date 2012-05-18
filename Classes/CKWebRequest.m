//
//  CKWebRequest.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKWebRequest.h"
#import "CKWebRequestManager.h"

NSString * const CKWebRequestHTTPErrorDomain = @"CKWebRequestHTTPErrorDomain";

@interface CKWebRequest () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLResponse *response;

@property (nonatomic, retain) NSMutableData *data;

@property (nonatomic, copy) void (^completionBlock)(id response, NSURLResponse *urlResponse, NSError *error);

@end

@implementation CKWebRequest

@synthesize connection, request, response;
@synthesize data, completionBlock;

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

- (id)initWithURLRequest:(NSURLRequest *)aRequest completion:(void (^)(id, NSURLResponse *, NSError *))block {
    if (self = [super init]) {
        self.request = aRequest;
        self.completionBlock = block;
    }
    return self;
}

#pragma mark - Convinience methods

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url completion:(void (^)(id, NSURLResponse *, NSError *))block {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    return [self scheduledRequestWithURLRequest:request completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request completion:(void (^)(id, NSURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return webRequest;
}

#pragma mark - LifeCycle

- (void)start {
    [self.connection start];
}

- (void)cancel {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
    self.response = aResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData {
    [self.data appendData:someData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.completionBlock(self.data, self.response, nil);
    });
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.completionBlock(nil, self.response, error);
    });
}

#pragma mark - Getters

- (NSURL *)URL {
    return self.request.URL;
}

@end
