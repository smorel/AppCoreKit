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

@interface CKWebService : NSObject {
	NSString *_username;
	NSString *_password;
}

@property (retain, readwrite) NSString *username;
@property (retain, readwrite) NSString *password;

- (CKWebRequest *)performRequest:(CKWebRequest *)request;

@end
