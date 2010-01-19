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
@synthesize transformer = _transformer;
@synthesize timestamp = _timestamp;
@synthesize url = _url;

- (id)initWithURL:(NSURL *)url {
	if (self = [super init]) {
		_delegate = nil;
		_transformer = nil;
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

+ (CKWebRequest *)requestWithURLString:(NSString *)url params:(NSDictionary *)params {
	NSURL *theURL = params ? [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url, [NSString stringWithQueryDictionary:params]]] : url;
	return [[[CKWebRequest alloc] initWithURL:theURL] autorelease];
}

@end