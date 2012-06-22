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
#import "CKWebRequestManager.h"

NSString* const CKWebSourceErrorNotification = @"CKWebSourceErrorNotification";

@interface CKWebSource ()
@property (nonatomic, retain) CKWebRequest *request;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) NSRange range;
@end

@implementation CKWebSource{
	CKWebRequest *_request;
	NSUInteger _requestedBatchSize;
	CKWebSourceRequestBlock _requestBlock;
    CKWebSourceCompletionBlock _completionBlock;
	
	id _webSourceDelegate;
}

@synthesize request = _request;
@synthesize requestBlock = _requestBlock;
@synthesize completionBlock = _completionBlock;
@synthesize webSourceDelegate = _webSourceDelegate;
@dynamic hasMore;
@dynamic isFetching;
@dynamic currentIndex;
@dynamic range;

- (void)dealloc {
	[self cancelFetch];
	[_requestBlock release];
    [_completionBlock release];
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
    
    self.request.completionBlock = ^(id value, NSHTTPURLResponse *response, NSError *error){
        if (error) 
            [self didFailWithError:error];
        else
            [self didReceiveValue:value];
    };
	
	if (self.request) {
        [[CKWebRequestManager sharedManager] scheduleRequest:self.request];
		self.isFetching = YES;
		return YES;
	}
    
	return NO;
}

- (void)cancelFetch {
	[self.request cancel];
	self.request = nil;
	[super cancelFetch];
}

- (void)reset {
	[self cancelFetch];
	[super reset];
}

#pragma mark Callback

- (void)didReceiveValue:(id)value {
	
	id newItems = nil;
	if(_webSourceDelegate && [_webSourceDelegate conformsToProtocol:@protocol(CKWebSourceDelegate)]){
		newItems = [_webSourceDelegate webSource:self transform:value];
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
	else if(_completionBlock){
		_completionBlock(value, nil);
	}
}

- (void)didFailWithError:(NSError *)error {
	CKDebugLog(@"%@", error);
	self.isFetching = NO;
	self.request = nil;
	
	if(_webSourceDelegate && [_webSourceDelegate conformsToProtocol:@protocol(CKWebSourceDelegate)]
	   && [_webSourceDelegate respondsToSelector:@selector(webSource:didFailWithError:)]){
		[_webSourceDelegate webSource:self didFailWithError:error];
	}
	else if(_completionBlock){
		_completionBlock(nil, error);
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
