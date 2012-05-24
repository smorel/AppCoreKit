//
//  CKWebRequest.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

OBJC_EXPORT NSString * const CKWebRequestHTTPErrorDomain;

@interface CKWebRequest : NSObject

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, copy) void (^completionBlock)(id response, NSHTTPURLResponse *urlResponse, NSError *error);
@property (nonatomic, copy) id (^transformBlock)(id value); //Called to apply a possible transformation to the response before the completion block

@property (nonatomic, assign) id<NSURLConnectionDelegate, NSURLConnectionDataDelegate> delegate; //Forward URL connection delegate if nessesary
@property (nonatomic, retain, readonly) NSString *downloadPath; //Need to be set at initialization 
@property (nonatomic, readonly) CGFloat progress; //KVO compilent

//See CKWebRequest+Initialization.h for other init and convinience methods
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

- (void)start; //Start on the currentRunLoop. Recommended to schedule with CKWebRequestManager
- (void)startOnRunLoop:(NSRunLoop*)runLoop;
- (void)cancel;

@end

#import "CKWebRequest+Initialization.h"
