//
//  CKWebRequest.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
OBJC_EXPORT NSString * const CKWebRequestHTTPErrorDomain;

@interface CKWebRequest : NSObject

///-----------------------------------
/// @name Initializing WebRequest Objects
///-----------------------------------

/** 
 */
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/** 
 */
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;


///-----------------------------------
/// @name Configuring the WebRequest
///-----------------------------------

/**
 */
@property (nonatomic, readonly) NSURL *URL;

/** Need to be set at initialization 
 */
@property (nonatomic, retain, readonly) NSString *downloadPath; 


/** Overwrite default credential
 */
@property (nonatomic, retain) NSURLCredential *credential;


///-----------------------------------
/// @name Reacting to WebRequest Events
///-----------------------------------

/** If urlResponse is nil, the data is from the cache
 */
@property (nonatomic, copy) void (^completionBlock)(id response, NSHTTPURLResponse *urlResponse, NSError *error);

/** 
 */
@property (nonatomic, copy) void (^cancelBlock)(void);

/** Called to apply a possible transformation to the response before the completion block
 */
@property (nonatomic, copy) id (^transformBlock)(id value);

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/** Forward URL connection delegate if nessesary
 */
@property (nonatomic, assign) id<NSURLConnectionDelegate, NSURLConnectionDataDelegate> delegate; 


///-----------------------------------
/// @name Getting the WebRequest status
///-----------------------------------

/** 
 */
@property (nonatomic, readonly) CGFloat progress;


///-----------------------------------
/// @name Executing the WebRequest
///-----------------------------------

/** Start on the currentRunLoop. Recommended to schedule with CKWebRequestManager
 */
- (void)start;

/** 
 */
- (void)startOnRunLoop:(NSRunLoop*)runLoop;

///-----------------------------------
/// @name Cancelling the WebRequest
///-----------------------------------

/** 
 */
- (void)cancel;

@end

#import "CKWebRequest+Initialization.h"
