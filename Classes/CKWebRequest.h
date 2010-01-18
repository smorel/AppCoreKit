//
//  CKWebRequest.h
//  CloudKit
//
//  Created by Fred Brunel on 09-11-09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKWebRequestDelegate;

@interface CKWebRequest : NSObject {
	id<CKWebRequestDelegate> _delegate;
	NSURL *_url;
	NSDate *_timestamp;
}

@property (nonatomic, readonly) id<CKWebRequestDelegate> delegate;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSDate *timestamp;

// Create a request from a "method"
// "method" is an URL and a (optional) base path (e.g., http://google.com/search)
// "params" is a key/value dictionary with the query to be appended to the method (e.g., q="example")

+ (CKWebRequest *)requestWithMethod:(NSString *)method params:(NSDictionary *)params delegate:(id<CKWebRequestDelegate>)delegate;

@end

//

@protocol CKWebRequestDelegate <NSObject> @optional
- (void)request:(CKWebRequest *)request didReceiveContent:(id)content;
- (void)request:(CKWebRequest *)request didFailWithError:(NSError *)error;
@end
