//
//  CKWebSource.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKWebSource.h"
#import "CKDebug.h"
#import "CKAlertView.h"
#import "CKLocalization.h"

@interface CKWebSource ()
@property (nonatomic, retain) CKWebRequest2 *request;
@end

@implementation CKWebSource

@synthesize request = _request;
@synthesize requestBlock = _requestBlock;
@synthesize transformBlock = _transformBlock;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc {
	[self cancelFetch];
	[_requestBlock release];
	[_transformBlock release];
	[super dealloc];
}

//

- (BOOL)fetchNextItems:(NSUInteger)batchSize {
	if ((_fetching == YES) || (_hasMore == NO)) 
		return NO;
	
	_requestedBatchSize = batchSize;
	self.request = _requestBlock(NSMakeRange(_currentIndex, batchSize));
	//[_requestBlock release];
	
	if (self.request) {
		self.request.delegate = self;
		[self.request start];
		_fetching = YES;
		return YES;
	}

	return NO;
}

- (void)cancelFetch {
	[self.request cancel];
	self.request.delegate = nil;
	self.request = nil;
	[super cancelFetch];
}

- (void)reset {
	[self cancelFetch];
	[super reset];
}

#pragma mark CKWebRequestDelegate

- (void)request:(id)request didReceiveData:(NSData *)data withResponseHeaders:(NSDictionary *)headers {
	return;
}

- (void)request:(id)request didReceiveValue:(id)value {
	id items = _transformBlock(value);
	
	if (items) {	
		NSAssert([items isKindOfClass:[NSArray class]], @"Transformed value should be an array of items");
		[self performSelector:@selector(addItems:) withObject:items];
	}
	
	_currentIndex += [items count];
	_hasMore = (_currentIndex < _requestedBatchSize) ? NO : YES;
	_fetching = NO;
	self.request = nil;
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	CKDebugLog(@"%@", error);
	_fetching = NO;
	self.request = nil;
	
	// TODO: Makes the alert optional and allow the request to be restarted.
	if (YES) {
		CKAlertView *alertView = 
		[[[CKAlertView alloc] initWithTitle:@"Fetching Error"
									message:[NSString stringWithFormat:@"%d %@", [error code], [error localizedDescription]]
								   delegate:self
						  cancelButtonTitle:_(@"Dismiss")
						  otherButtonTitles:nil] autorelease];
		[alertView show];
	}
}

@end
