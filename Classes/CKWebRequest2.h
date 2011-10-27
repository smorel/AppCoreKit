//
//  CKWebRequest2.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

//  This class is a re-implementation of CKWebRequest not dependent on 
//  ASIHTTPRequest.

//  TODO: Implement the authentication challenge.
//  TODO: Implement the transformer.
//  TODO: Check caching behavior regarding the "offline" mode.

#import <Foundation/Foundation.h>

OBJC_EXPORT NSString * const CKWebRequestHTTPErrorDomain;

typedef id   (^CKWebRequestTransformBlock)(id value);
typedef void (^CKWebRequestSuccessBlock)(id value);
typedef void (^CKWebRequestFailureBlock)(NSError* error);
typedef void (^CKWebRequestCompletionBlock)(id value, NSHTTPURLResponse* response, NSError* error);


@protocol  CKWebRequestDelegate;


/** TODO
 */
@interface CKWebRequest2 : NSOperation {
	NSMutableURLRequest *theRequest;
	NSURLConnection *theConnection;
	NSHTTPURLResponse *theResponse;
	NSMutableData *theReceivedData;
	id theUserInfo;
	NSObject<CKWebRequestDelegate> *theDelegate;
	long long byteReceived;
	
	NSString* destinationPath;
	BOOL allowDestinationOverwrite;
	NSOutputStream* destinationStream;
	
	BOOL executing;
	BOOL finished;
	BOOL cancelled;

    // Authentication
    
    BOOL validatesSecureCertificate;
    NSURLCredential *_credential;
    
    // Callbacks
    
	CKWebRequestTransformBlock theTransformBlock;
	CKWebRequestSuccessBlock theSuccessBlock;
	CKWebRequestFailureBlock theFailureBlock;
	CKWebRequestCompletionBlock theCompletedBlock;
}

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, assign) BOOL validatesSecureCertificates;
@property (nonatomic, retain) NSURLCredential *credential;
@property (nonatomic, assign) NSObject<CKWebRequestDelegate> *delegate;
@property (nonatomic, copy) CKWebRequestCompletionBlock completedBlock;//Wanted to call it completionBlock but there is already one in NSOperation called asynchroneously using GCD
@property (nonatomic, copy) CKWebRequestTransformBlock transformBlock;
@property (nonatomic, copy) CKWebRequestSuccessBlock successBlock;
@property (nonatomic, copy) CKWebRequestFailureBlock failureBlock;

+ (NSString *)defaultUserAgentString;

- (void)setMethod:(NSString *)method;
- (void)setBodyData:(NSData *)bodyData;

// Configure the request to send the params as a <application/x-www-form-urlencoded> POST
- (void)setBodyParams:(NSDictionary *)params;

- (void)setDestination:(NSString *)path allowOverwrite:(BOOL)allowOverwrite;

- (void)startAsynchronous;

//

- (id)initWithURL:(NSURL *)URL;

+ (id)requestWithURL:(NSURL *)URL;
+ (id)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params;
+ (id)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate;
+ (id)requestWithMethod:(NSString *)method URLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate;

+ (NSCachedURLResponse *)cachedResponseForURL:(NSURL *)URL;

@end

//

/** TODO
 */
@protocol CKWebRequestDelegate <NSObject> @optional
- (void)request:(id)request didReceivePartialData:(NSData*)data progress:(NSNumber*)progress;
- (void)requestDidFinishLoading:(id)request;

- (void)request:(id)request didReceiveResponse:(NSURLResponse *)response;
- (void)request:(id)request didReceiveData:(NSData *)data withResponseHeaders:(NSDictionary *)headers;
- (void)request:(id)request didReceiveValue:(id)value;
- (void)request:(id)request didFailWithError:(NSError *)error;
@end