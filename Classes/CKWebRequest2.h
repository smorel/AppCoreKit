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

@protocol  CKWebRequestDelegate;

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
}

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, assign) NSObject<CKWebRequestDelegate> *delegate;

+ (NSString *)defaultUserAgentString;

- (void)setMethod:(NSString *)method;
- (void)setBodyData:(NSData *)bodyData;
- (void)setDestination:(NSString *)path allowOverwrite:(BOOL)allowOverwrite;

//

- (id)initWithURL:(NSURL *)URL;

+ (CKWebRequest2 *)requestWithURL:(NSURL *)URL;
+ (CKWebRequest2 *)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params;
+ (CKWebRequest2 *)requestWithURLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate;
+ (CKWebRequest2 *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString params:(NSDictionary *)params delegate:(id)delegate;

+ (NSCachedURLResponse *)cachedResponseForURL:(NSURL *)URL;

@end

//

@protocol CKWebRequestDelegate <NSObject> @optional
- (void)request:(id)request didReceivePartialData:(NSData*)data progress:(NSNumber*)progress;
- (void)requestDidFinishLoading:(id)request;

- (void)request:(id)request didReceiveData:(NSData *)data withResponseHeaders:(NSDictionary *)headers;
- (void)request:(id)request didReceiveValue:(id)value;
- (void)request:(id)request didFailWithError:(NSError *)error;
@end