//
//  CKWebRequest.h
//  CloudKit
//
//  Created by Fred Brunel on 09-11-09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKWebRequestDelegate;
@protocol CKWebResponseTransformer;

@interface CKWebRequest : NSObject {
	id<CKWebRequestDelegate> _delegate;
	id<CKWebResponseTransformer> _transformer;
	NSURL *_url;
	NSDate *_timestamp;
}

@property (assign, readwrite) id<CKWebRequestDelegate> delegate;
@property (assign, readwrite) id<CKWebResponseTransformer> transformer;
@property (readonly) NSURL *url;
@property (readonly) NSDate *timestamp;

// Create a request from a URL string
// "url" is an URL as a string with an optional base path (e.g., http://google.com/search)
// "params" is the query as a key/value NSDictionary; it will be appended as a query string to the URL (e.g., <url>?q="example")

+ (CKWebRequest *)requestWithURLString:(NSString *)url params:(NSDictionary *)params;

@end

//

@protocol CKWebRequestDelegate <NSObject> @optional
- (void)request:(CKWebRequest *)request didReceiveContent:(id)content;
- (void)request:(CKWebRequest *)request didFailWithError:(NSError *)error;
@end

//

@protocol CKWebResponseTransformer <NSObject>
- (id)request:(CKWebRequest *)request transformContent:(id)content;
@end