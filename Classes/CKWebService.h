//
//  CKWebService.h
//  CloudKit
//
//  Created by Fred Brunel on 09-11-10.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

// TODO: the CKWebService should act as a "session" over the web service, the way
// clients authenticate should be customizable. In this version, only the basic
// authentication is supported.

#import <Foundation/Foundation.h>

#import "CKWebRequest.h"
#import "Reachability.h"

@interface CKWebService : NSObject {
	Reachability *_reachability;
	NSURL *_baseURL;
	NSMutableDictionary *_defaultParams;
	NSMutableDictionary *_defaultHeaders;
	NSString *_username;
	NSString *_password;
}

@property (nonatomic, retain, readwrite) NSURL *baseURL;
@property (nonatomic, retain, readonly) NSMutableDictionary *defaultParams;
@property (nonatomic, retain, readonly) NSMutableDictionary *defaultHeaders;

- (void)setDefaultBasicAuthWithUsername:(NSString *)username password:(NSString *)password;

//

- (id)performRequest:(CKWebRequest *)request;

- (id)getRequestForPath:(NSString *)path params:(NSDictionary *)params;
- (id)getPath:(NSString *)path params:(NSDictionary *)params delegate:(id)delegate;

@end
