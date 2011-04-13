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

NSString* const CKWebSourceErrorNotification = @"CKWebSourceErrorNotification";

@interface CKWebSource ()
@property (nonatomic, retain) CKWebRequest2 *request;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) NSUInteger currentIndex;
@end

@implementation CKWebSource

@synthesize request = _request;
@synthesize requestBlock = _requestBlock;
@synthesize transformBlock = _transformBlock;
@synthesize failureBlock = _failureBlock;
@synthesize webSourceDelegate = _webSourceDelegate;
@dynamic hasMore;
@dynamic isFetching;
@dynamic currentIndex;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc {
	[self cancelFetch];
	[_requestBlock release];
	[_transformBlock release];
	[_failureBlock release];
	_webSourceDelegate = nil;
	[super dealloc];
}

//

- (BOOL)fetchNextItems:(NSUInteger)batchSize {
	if ((self.isFetching == YES) || (self.hasMore == NO)
		|| (_limit > 0 && self.currentIndex >= _limit) ) 
		return NO;
	
	_requestedBatchSize = batchSize;
	if(_webSourceDelegate && [_webSourceDelegate conformsToProtocol:@protocol(CKWebSourceDelegate)]){
		self.request = [_webSourceDelegate webSource:self requestForRange:NSMakeRange(self.currentIndex, batchSize)];
	}
	else if(_requestBlock){
		self.request = _requestBlock(NSMakeRange(self.currentIndex, batchSize));
	}
	else{
		NSLog(NO,@"Invalid WebSource Definition : Needs to define _requestBlock (OS4) or set a delegate with protocol CKWebSourceDelegate (OS3)");
	}
	
	if (self.request) {
		self.request.delegate = self;
		[self.request startAsynchronous];
		self.isFetching = YES;
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
	
	id newItems = nil;
	if(_webSourceDelegate && [_webSourceDelegate conformsToProtocol:@protocol(CKWebSourceDelegate)]){
		newItems = [_webSourceDelegate webSource:self transform:value];
	}
	else if(_transformBlock){
		newItems = _transformBlock(value);
	}
	else{
		NSAssert(NO,@"Invalid WebSource Definition : Needs to define _transformBlock (OS4) or set a delegate with protocol CKWebSourceDelegate (OS3)");
	}
	
	if (newItems) {	
		NSAssert([newItems isKindOfClass:[NSArray class]], @"Transformed value should be an array of items");
		[self performSelector:@selector(addItems:) withObject:newItems];
	}
	
	self.currentIndex += [newItems count];
	self.hasMore = self.hasMore && (([newItems count] < _requestedBatchSize) ? NO : YES);
	self.isFetching = NO;
	self.request = nil;
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	CKDebugLog(@"%@", error);
	self.isFetching = NO;
	self.request = nil;
	
	if(_webSourceDelegate && [_webSourceDelegate conformsToProtocol:@protocol(CKWebSourceDelegate)]
	   && [_webSourceDelegate respondsToSelector:@selector(webSource:didFailWithError:)]){
		[_webSourceDelegate webSource:self didFailWithError:error];
	}
	else if(_failureBlock){
		_failureBlock(error);
	}
	else{
		//NSAssert(NO,@"Invalid WebSource Definition : Needs to define _failureBlock (OS4) or set a delegate with protocol CKWebSourceDelegate (OS3)");
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CKWebSourceErrorNotification object:self];
	
	// TODO: Makes the alert optional and allow the request to be restarted.
#ifdef DEBUG
		/*CKAlertView *alertView = 
		[[[CKAlertView alloc] initWithTitle:@"Fetching Error"
									message:[NSString stringWithFormat:@"%d %@", [error code], [error localizedDescription]]
								   delegate:self
						  cancelButtonTitle:_(@"Dismiss")
						  otherButtonTitles:nil] autorelease];
		[alertView show];*/
#endif
}

@end
