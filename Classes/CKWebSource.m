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
@property (nonatomic, retain) CKWebRequest *request;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) NSRange range;
@end

@implementation CKWebSource

@synthesize request = _request;
@synthesize requestBlock = _requestBlock;
@synthesize transformBlock = _transformBlock;
@synthesize failureBlock = _failureBlock;
@synthesize webSourceDelegate = _webSourceDelegate;
@synthesize successBlock = _successBlock;
@synthesize launchRequestBlock = _launchRequestBlock;
@dynamic hasMore;
@dynamic isFetching;
@dynamic currentIndex;
@dynamic range;

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
	[_successBlock release];
	[_launchRequestBlock release];
	_webSourceDelegate = nil;
	[super dealloc];
}

//

- (BOOL)fetchRange:(NSRange)range {
	self.range = range;
	if ((self.isFetching == YES) || (self.hasMore == NO)) 
		return NO;
	
	_requestedBatchSize = range.length;
	if(_webSourceDelegate && [_webSourceDelegate conformsToProtocol:@protocol(CKWebSourceDelegate)]){
		self.request = [_webSourceDelegate webSource:self requestForRange:self.range];
	}
	else if(_requestBlock){
		self.request = _requestBlock(self.range);
	}
	else{
		CKDebugLog(NO,@"Invalid WebSource Definition : Needs to define _requestBlock (OS4) or set a delegate with protocol CKWebSourceDelegate (OS3)");
	}
	
	if (self.request) {
		self.request.delegate = self;
        if(_launchRequestBlock){
            _launchRequestBlock(self.request);
        }
        else{
            [self.request startAsynchronous];
        }
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
        newItems = value;
		//NSAssert(NO,@"Invalid WebSource Definition : Needs to define _transformBlock (OS4) or set a delegate with protocol CKWebSourceDelegate (OS3)");
	}
	
	self.hasMore = self.hasMore && (([newItems count] < _requestedBatchSize) ? NO : YES);
	self.isFetching = NO;
	self.request = nil;
    
    if (newItems) {	
		NSAssert([newItems isKindOfClass:[NSArray class]], @"Transformed value should be an array of items");
		[self performSelector:@selector(addItems:) withObject:newItems];
	}
	
	if(_webSourceDelegate && [_webSourceDelegate respondsToSelector:@selector(webSourceDidSuccess:)]){
		[_webSourceDelegate webSourceDidSuccess:self];
	}
	else if(_successBlock){
		_successBlock();
	}
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
