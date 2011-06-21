//
//  CKWebService2.h
//  CloudKit
//
//  Created by Fred Brunel on 09-05-11.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKWebRequest2.h"

@class Reachability;

@interface CKWebService2 : NSObject {
	Reachability *_reachability;
	NSURL *_baseURL;
	NSMutableDictionary *_defaultParams;
	NSMutableDictionary *_defaultHeaders;
}

@property (nonatomic, retain, readwrite) NSURL *baseURL;
@property (nonatomic, retain, readonly) NSMutableDictionary *defaultParams;
@property (nonatomic, retain, readonly) NSMutableDictionary *defaultHeaders;

//

+ (id)sharedWebService;
+ (void)setSharedWebService:(id)sharedWebService;

//

- (id)performRequest:(CKWebRequest2 *)request;

- (id)getRequestForPath:(NSString *)path params:(NSDictionary *)params;
- (id)getPath:(NSString *)path params:(NSDictionary *)params delegate:(id)delegate;

@end
