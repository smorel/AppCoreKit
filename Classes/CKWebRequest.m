//
//  CKWebRequest.m
//  CloudKit
//
//  Created by Fred Brunel on 09-11-09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebRequest.h"
#import "CKNSStringAdditions.h"

@implementation CKWebRequest

@synthesize delegate = _delegate;
@synthesize timestamp = _timestamp;
@synthesize url = _url;

- (id)initWithURL:(NSURL *)url delegate:(id<CKWebRequestDelegate>)delegate {
	if (self = [super init]) {
		_delegate = delegate;
		_url = [url retain];
		_timestamp = [[NSDate date] retain];		
	}
	return self;
}

- (void)dealloc {
	[_url release];
	[_timestamp release];
	[super dealloc];
}

//

+ (CKWebRequest *)requestWithMethod:(NSString *)method params:(NSDictionary *)params delegate:(id<CKWebRequestDelegate>)delegate {
	NSURL *url = params ? [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", method, [NSString stringWithQueryDictionary:params]]] : method;
	return [[[CKWebRequest alloc] initWithURL:url delegate:delegate] autorelease];
}

@end