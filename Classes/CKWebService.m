//
//  YPWebService.m
//  YellowPages
//
//  Created by Fred Brunel on 09-11-10.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebService.h"

//

@implementation CKWebService

@synthesize username = _username;
@synthesize password = _password;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

#pragma mark Create Requests

- (CKWebRequest *)performRequest:(CKWebRequest *)request {
	[request performSelector:@selector(connect:password:) withObject:_username withObject:_password];
	return request;
}

@end