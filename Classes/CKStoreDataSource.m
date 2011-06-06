//
//  CKStoreDataSource.m
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-02.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStoreDataSource.h"
#import <Cloudkit/CKDebug.h>
#import <Cloudkit/CKItem.h>

NSString* const CKStoreSourceErrorNotification = @"CKStoreSourceErrorNotification";
static NSOperationQueue *theSharedStoreDataSourceQueue = nil;


@interface CKStoreRequest ()

- (void)markAsExecuting;
- (void)markAsFinished;
- (void)markAsCancelled;

@end

@implementation CKStoreRequest 
@synthesize store = _store;
@synthesize predicateFormat = _predicateFormat;
@synthesize predicateArguments = _predicateArguments;
@synthesize sortKeys = _sortKeys;
@synthesize range = _range;
@synthesize delegate = _delegate;

+ (CKStoreRequest*)requestWithPredicateFormat:(NSString*)format arguments:(NSArray*)arguments range:(NSRange)range sortKeys:(NSArray*)sortKeys store:(CKStore*)store{
	return [[[CKStoreRequest alloc]initWithPredicateFormat:format arguments:arguments range:range sortKeys:sortKeys store:store]autorelease];
}

- (id)initWithPredicateFormat:(NSString*)format arguments:(NSArray*)arguments range:(NSRange)theRange sortKeys:(NSArray*)sortKeys store:(CKStore*)theStore{
	[super init];
	self.store = theStore;
	self.predicateFormat = format;
	self.predicateArguments = arguments;
	self.range = theRange;
	self.sortKeys = sortKeys;
	return self;
}

- (void)dealloc{
	self.store = nil;
	self.predicateFormat = nil;
	self.predicateArguments = nil;
	self.sortKeys = nil;
	[super dealloc];
}

//- (NSArray *)fetchItemsWithFormat:(NSString *)predicateFormat arguments:(NSArray *)arguments range:(NSRange)range sortedBy:(NSString*)sortedBy

- (void)startAsynchronous{
	if(theSharedStoreDataSourceQueue == nil){
		theSharedStoreDataSourceQueue = [[NSOperationQueue alloc] init];
		[theSharedStoreDataSourceQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
	[theSharedStoreDataSourceQueue addOperation:self];
}

 
- (void)start {
	if([self isCancelled]){
		[self markAsFinished];
		return;
	}
	
	if ( [self isExecuting] || [self isFinished]){
		return;
	}
	
	[self markAsExecuting];
	
	NSArray* results = [_store fetchItemsWithFormat:_predicateFormat arguments:_predicateArguments range:_range sortedByKeys:self.sortKeys];
	if(_delegate && [_delegate respondsToSelector:@selector(request:didReceiveValue:)]){
		[_delegate request:self didReceiveValue:results];
	}
	
	[self markAsFinished];
}

- (void)cancel {
	[self markAsCancelled];
}


#pragma mark NSOperation

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return executing;
}

- (BOOL)isFinished {
	return finished;
}

- (BOOL)isCancelled {
	return cancelled;
}

- (void)markAsExecuting {
	if (executing) return;
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
}

- (void)markAsCancelled {
	if(cancelled)return;
	
	[self willChangeValueForKey:@"isCancelled"];
	cancelled = YES;
	[self didChangeValueForKey:@"isCancelled"];
	
	if(executing){
		[self markAsFinished];
	}
}

- (void)markAsFinished {
	if (finished) return;
	
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"isExecuting"];
	executing = NO;
	finished = YES;
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}


@end


@interface CKStoreDataSource ()
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, retain) CKStoreRequest* request;
@end

@implementation CKStoreDataSource
@synthesize requestBlock = _requestBlock;
@synthesize transformBlock = _transformBlock;
@synthesize failureBlock = _failureBlock;
@synthesize successBlock = _successBlock;
@dynamic hasMore;
@dynamic isFetching;
@dynamic range;
@synthesize storeDelegate = _storeDelegate;
@synthesize request = _request;
@synthesize executeInBackground = _executeInBackground;

+ (CKStoreDataSource*)dataSource{
	return [[[CKStoreDataSource alloc]init]autorelease];
}

+ (CKStoreDataSource*)synchronousDataSource{
	CKStoreDataSource* source = [CKStoreDataSource dataSource];
	source.executeInBackground = NO;
	return source;
}

- (id)init{
	[super init];
	self.executeInBackground = YES;
	return self;
}

- (void)dealloc {
	[self cancelFetch];
	self.requestBlock = nil;
	self.transformBlock = nil;
	self.failureBlock = nil;
	self.successBlock = nil;
	self.request = nil;
	[super dealloc];
}

- (BOOL)fetchRange:(NSRange)range {
	self.range = range;
	if ((self.isFetching == YES) || (self.hasMore == NO)) 
		return NO;
	
	self.request = nil;
	if(_storeDelegate && [_storeDelegate conformsToProtocol:@protocol(CKStoreDataSourceDelegate)]){
		self.request = [_storeDelegate storeSource:self requestForRange:self.range];
	}
	else if(_requestBlock){
		self.request = _requestBlock(self.range);
	}
	else{
		NSLog(NO,@"Invalid storeSource Definition : Needs to define _requestBlock (OS4) or set a delegate with protocol CKStoreDataSourceDelegate (OS3)");
	}
	
	if (self.request) {
		self.request.delegate = self;
		self.isFetching = YES;
		if(_executeInBackground){
			[self.request startAsynchronous];
		}
		else{
			[self.request start];
		}
		return YES;
	}
	
	return NO;
}

- (void)request:(id)request didReceiveValue:(id)value{
	//MAKE a dictionary representation of value instead of CKItems ...
	NSMutableArray* dictionaryRepresentation = [NSMutableArray array];
	for(CKItem* item in value){
		[dictionaryRepresentation addObject:[item propertyListRepresentation]];
	}
	
	 id newItems = nil;
	 if(_storeDelegate && [_storeDelegate conformsToProtocol:@protocol(CKStoreDataSourceDelegate)]){
		 newItems = [_storeDelegate storeSource:self transform:dictionaryRepresentation];
	 }
	 else if(_transformBlock){
		 newItems = _transformBlock(dictionaryRepresentation);
	 }
	 else{
		 NSAssert(NO,@"Invalid WebSource Definition : Needs to define _transformBlock (OS4) or set a delegate with protocol CKWebSourceDelegate (OS3)");
	 }
	 
	 if (newItems) {	
		 NSAssert([newItems isKindOfClass:[NSArray class]], @"Transformed value should be an array of items");
		 [self performSelector:@selector(addItems:) withObject:newItems];
	 }
	 
	 self.hasMore = self.hasMore && (([newItems count] < self.range.length) ? NO : YES);
	 self.isFetching = NO;
	 self.request = nil;
	
	if(_successBlock){
		_successBlock();
	}
}

- (void)request:(id)request didFailWithError:(NSError *)error{
	 CKDebugLog(@"%@", error);
	 self.isFetching = NO;
	 self.request = nil;
	 
	 if(_storeDelegate && [_storeDelegate conformsToProtocol:@protocol(CKStoreDataSourceDelegate)]
		&& [_storeDelegate respondsToSelector:@selector(storeSource:didFailWithError:)]){
		 [_storeDelegate storeSource:self didFailWithError:error];
	 }
	 else if(_failureBlock){
		 _failureBlock(error);
	 }
	 else{
		 //NSAssert(NO,@"Invalid WebSource Definition : Needs to define _failureBlock (OS4) or set a delegate with protocol CKWebSourceDelegate (OS3)");
	 }
	 
	 [[NSNotificationCenter defaultCenter] postNotificationName:CKStoreSourceErrorNotification object:self];
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

@end
