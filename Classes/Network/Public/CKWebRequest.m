//
//  CKWebRequest.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URIQuery.h"
#import "CKWebRequest+Initialization.h"
#import "CKWebRequest.h"
#import "CKWebRequestManager.h"
#import "CKWebDataConverter.h"
#import "CKNetworkActivityManager.h"
#import "CKVersion.h"
#import "CKDebug.h"

NSString * const CKWebRequestHTTPErrorDomain = @"CKWebRequestHTTPErrorDomain";

@interface CKWebRequest () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSHTTPURLResponse *response;

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSFileHandle *handle;
@property (nonatomic, retain, readwrite) NSString *downloadPath;

@property (nonatomic, assign, readwrite) CGFloat progress;
@property (nonatomic, assign) NSUInteger retriesCount;

@property (atomic, assign, getter = isCancelled) BOOL cancelled;
@property (nonatomic, assign) dispatch_group_t operationsGroup;
@property (nonatomic, assign) dispatch_group_t startGroup;

@end

@implementation CKWebRequest

@synthesize connection, request, response, cancelled, operationsGroup, startGroup;
@synthesize completionBlock, transformBlock, cancelBlock;
@synthesize data, handle, downloadPath, credential;
@synthesize delegate, progress, retriesCount;

#pragma mark - Init/Dealloc

- (id)initWithURLRequest:(NSURLRequest *)aRequest parameters:(NSDictionary *)parameters transform:(id (^)(id value))transform completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    if (self = [super init]) {
        NSMutableURLRequest *mutableRequest = aRequest.mutableCopy;
        if (parameters) {
            NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", aRequest.URL.absoluteString, [NSString stringWithQueryDictionary:parameters]]];
            [mutableRequest setURL:newURL];
        }
        
        self.request = mutableRequest;
        [mutableRequest release];
        
        self.completionBlock = block;
        self.transformBlock = transform;
        self.data = [[[NSMutableData alloc] init] autorelease];
        self.cancelled = NO;
        self.operationsGroup = dispatch_group_create();
    }
    return self;
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest parameters:(NSDictionary *)parameters downloadAtPath:(NSString *)path completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    if (self = [self initWithURLRequest:aRequest parameters:parameters completion:block]) {
        unsigned long long existingDataLenght = 0;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            unsigned long long existingDataLenght = [attributes fileSize];
            NSString* bytesStr = [NSString stringWithFormat:@"bytes=%qu-", existingDataLenght];
            
            NSMutableURLRequest *mutableRequest = self.request.mutableCopy;
            [mutableRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
            self.request = mutableRequest;
            [mutableRequest release];
        }
        else 
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        
        self.handle = [NSFileHandle fileHandleForWritingAtPath:path];
        [self.handle seekToFileOffset:existingDataLenght];
        
        self.downloadPath = path;
        self.retriesCount = 0;
        self.data = nil;
        self.cancelled = NO;
        self.operationsGroup = dispatch_group_create();
    }
    return self;
}

- (void)dealloc {
    self.connection = nil;
    self.request = nil;
    self.response = nil;
    self.data = nil;
    self.handle = nil;
    self.downloadPath = nil;
    self.completionBlock = nil;
    self.transformBlock = nil;
    self.cancelBlock = nil;
    if (self.startGroup)
        dispatch_release(self.startGroup);
    dispatch_release(self.operationsGroup);
    
    [super dealloc];
}

#pragma mark - LifeCycle

- (void)start {
    [self startOnRunLoop:[NSRunLoop currentRunLoop]];
}

- (void)startOnRunLoop:(NSRunLoop *)runLoop {
    CKAssert(self.connection == nil, @"Connection already started");
    
    if (self.startGroup)
        dispatch_release(self.startGroup);
    
    self.startGroup = dispatch_group_create();
    dispatch_group_async(self.startGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        dispatch_group_wait(self.operationsGroup, DISPATCH_TIME_FOREVER);
        
        self.progress = 0.0;
        self.cancelled = NO;
        
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:self.request];

        if (cachedResponse && [(NSHTTPURLResponse*)[cachedResponse response] statusCode] < 400 ) {
            [self connection:nil didReceiveResponse:cachedResponse.response];
            [self connection:nil didReceiveData:cachedResponse.data];
            [self connectionDidFinishLoading:nil];
        }
        else {
            self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO] autorelease];
            
            [self.connection scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
            [self.connection start];
            
            [[CKNetworkActivityManager defaultManager] addNetworkActivityForObject:self];
        }
    });
}

- (void)cancel {
    void (^doCancel)() = ^{
        if (!self.cancelled) {
            [self.connection cancel];
            self.connection = nil;
            self.cancelled = YES;
            
            [[CKNetworkActivityManager defaultManager] removeNetworkActivityForObject:self];
            
            if (self.cancelBlock)
                self.cancelBlock();
        }
    };
    
    if (self.startGroup)
        dispatch_group_notify(self.startGroup, dispatch_get_current_queue(), doCancel);
    else
        doCancel();
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *aCredential = self.credential ? self.credential : [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:[challenge protectionSpace]];
        
        if (aCredential) {
            [[challenge sender] useCredential:aCredential forAuthenticationChallenge:challenge];
            return;
        }
    }
    
    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSHTTPURLResponse *)aResponse {
    if (!self.isCancelled) {
        self.response = aResponse;
        
        if ([aResponse statusCode] >= 400) {
            self.handle = nil;
            self.data = [NSMutableData data];
            [[NSFileManager defaultManager] removeItemAtPath:self.downloadPath error:nil];
        }
        
        if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
            [self.delegate connection:aConnection didReceiveResponse:aResponse];  
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)someData {
    if (!self.isCancelled) {
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
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    self.progress = 1.0;
    
    
    dispatch_group_async(self.operationsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSError* converterError = nil;
        
        if(self.handle){
            [self.handle closeFile];
        }
        
        id object = self.isCancelled ? nil : [CKWebDataConverter convertData:self.data fromResponse:self.response error:&converterError];
        
        if(converterError != nil){
            if (self.completionBlock)
                self.completionBlock(object, self.response, converterError);
            
            if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)])
                [self.delegate connection:aConnection didFailWithError:converterError];
            
            return;
        }
        
        if (aConnection)
            [[CKNetworkActivityManager defaultManager] removeNetworkActivityForObject:self];
        
        if (self.transformBlock && !self.isCancelled) {
            id transformedObject = transformBlock(object);
            if (transformedObject)
                object = transformedObject;
        }
        
        if (!self.isCancelled) {
            dispatch_group_async(self.operationsGroup, dispatch_get_main_queue(), ^(void) {
                if (!self.isCancelled) {
                    self.cancelled = YES;
                    
                   // if (aConnection == nil)
                   //     self.response = nil;
                    
                    if (self.completionBlock)
                        self.completionBlock(object, self.response, nil);
                    
                    if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
                        [self.delegate connectionDidFinishLoading:aConnection];
                }
            });  
        }
    });
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if ([(NSHTTPURLResponse*)[cachedResponse response] statusCode] >= 400)
        return nil;
    
    NSCachedURLResponse *onDiskCachedResponse = [[[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data] autorelease];
    [[NSURLCache sharedURLCache] storeCachedResponse:onDiskCachedResponse forRequest:self.request];
    
    return nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    if (!([error code] == NSURLErrorTimedOut && [self retry] && self.handle)) {
        if ( !self.isCancelled ) {
            dispatch_group_async(self.operationsGroup, dispatch_get_main_queue(), ^(void) {
                if ( !self.isCancelled ) {
                    self.cancelled = YES;
                    if(self.completionBlock){
                        self.completionBlock(nil, self.response, error);
                    }
                    
                    if (aConnection)
                        [[CKNetworkActivityManager defaultManager] removeNetworkActivityForObject:self];
                    
                    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]){
                        [self.delegate connection:aConnection didFailWithError:error];
                    }
                }
            });
        }
    }
}

#pragma mark - Getters

- (BOOL)retry {
    if (self.retriesCount++ == 3)
        return NO;
    else {
      	[self cancel];
        self.connection = nil;
        [self start];
        return YES;  
    }
}

- (NSURL *)URL {
    return self.request.URL;
}

@end
