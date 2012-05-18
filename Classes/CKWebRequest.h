//
//  CKWebRequest.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSString * const CKWebRequestHTTPErrorDomain;

@interface CKWebRequest : NSObject

@property (nonatomic, readonly) NSURL *URL;

+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url completion:(void (^)(id, NSURLResponse*, NSError*))block;
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request completion:(void (^)(id, NSURLResponse*, NSError*))block;

- (id)initWithURL:(NSURL*)url completion:(void (^)(id, NSURLResponse*, NSError*))block;
- (id)initWithURLRequest:(NSURLRequest*)request completion:(void (^)(id, NSURLResponse*, NSError*))block;

- (void)start; //Start on the currentRunLoop. Recommended to schedule with CKWebRequestManager
- (void)cancel;

@end
