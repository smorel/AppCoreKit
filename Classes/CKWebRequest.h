//
//  CKWebRequest.h
//  CloudKit
//
//  Created by Fred Brunel on 09-11-09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

// TODO: How to solve the problem of establishing a "session" with credentials and
// how to allow client classes to customize the behavior for non-standard authentication
// TODO: the CKWebRequest should be initialized with a "session" (i.e. CKWebService)

#import <Foundation/Foundation.h>

@protocol CKWebRequestDelegate;
@protocol CKWebResponseTransformer;

@class ASIHTTPRequest;

@interface CKWebRequest : NSObject {
	id<CKWebRequestDelegate> _delegate;
	id<CKWebResponseTransformer> _transformer;
	id _userInfo;
	NSURL *_url;
	NSDate *_timestamp;
	ASIHTTPRequest *_httpRequest;
}

@property (nonatomic, assign) id<CKWebRequestDelegate> delegate;
@property (nonatomic, assign) id<CKWebResponseTransformer> transformer;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, retain) id userInfo;

// Create a request from a URL string
// <url> is an URL as a string with an optional base path (e.g., http://google.com/search)
// <params> is the query as a key/value NSDictionary; it will be appended as a query string to the URL (e.g., <url>?q="example")

+ (CKWebRequest *)requestWithURLString:(NSString *)url params:(NSDictionary *)params;

- (void)cancel;

@end

//

@protocol CKWebRequestDelegate <NSObject> @optional
- (void)request:(CKWebRequest *)request didReceiveContent:(id)content;
- (void)request:(CKWebRequest *)request didFailWithError:(NSError *)error;
//- (void)requestWasCancelled:(CKWebRequest *)request;
@end

//

@protocol CKWebResponseTransformer <NSObject>
- (id)request:(CKWebRequest *)request transformContent:(id)content;
@end

//