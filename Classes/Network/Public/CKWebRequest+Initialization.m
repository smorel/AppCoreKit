//
//  CKWebRequest+Initialization.m
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebRequest+Initialization.h"
#import "CKWebRequestManager.h"

@implementation CKWebRequest (Initialization)

- (id)initWithCompletion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    if (self = [self init]) {
        self.completionBlock = block;
    }
    return self;
}

- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters{
    return [self initWithURL:url parameters:parameters completion:nil];
}

- (id)initWithURL:(NSURL *)url completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self initWithURLRequest:aRequest completion:block];
}

- (id)initWithURL:(NSURL *)url transform:(id (^)(id))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self initWithURLRequest:aRequest transform:transform completion:block];
}

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self initWithURLRequest:aRequest parameters:parameters completion:block];
}

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters transform:(id (^)(id))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self initWithURLRequest:aRequest parameters:parameters transform:transform completion:block];
}

- (id)initWithURL:(NSURL *)url parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *aRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self initWithURLRequest:aRequest parameters:parameters downloadAtPath:path completion:block];
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    return [self initWithURLRequest:aRequest parameters:nil completion:block];
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    return [self initWithURLRequest:aRequest parameters:parameters transform:nil completion:block];
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest transform:(id (^)(id))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    return [self initWithURLRequest:aRequest parameters:nil transform:transform completion:block];
}

#pragma mark - Convinience methods

+ (CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters{
    return [self scheduledRequestWithURL:url parameters:parameters completion:nil];
}

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self scheduledRequestWithURLRequest:request completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self scheduledRequestWithURLRequest:request parameters:parameters completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self scheduledRequestWithURLRequest:request parameters:parameters downloadAtPath:path completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters transform:(id (^)(id))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self scheduledRequestWithURLRequest:request parameters:parameters transform:transform completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURL:(NSURL *)url transform:(id (^)(id))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    return [self scheduledRequestWithURLRequest:request transform:transform completion:block];
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return [webRequest autorelease];
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request transform:(id (^)(id))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request transform:transform completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return [webRequest autorelease];
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request parameters:parameters completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return [webRequest autorelease];
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request parameters:parameters downloadAtPath:path completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return [webRequest autorelease];
}

+ (CKWebRequest *)scheduledRequestWithURLRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters transform:(id (^)(id))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    CKWebRequest *webRequest = [[CKWebRequest alloc] initWithURLRequest:request parameters:parameters transform:transform completion:block];
    [[CKWebRequestManager sharedManager] scheduleRequest:webRequest];
    return [webRequest autorelease];
}

@end
