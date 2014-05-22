//
//  CKFeedSource.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFeedSource.h"
#import "NSObject+Invocation.h"

@interface CKFeedSource ()
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) NSRange range;
@end

@implementation CKFeedSource {
	id _delegate;
	BOOL _hasMore;
	BOOL _isFetching;
	NSRange _range;
}

@synthesize delegate = _delegate;
@synthesize hasMore = _hasMore;
@synthesize isFetching = _isFetching;
@synthesize range = _range;
@synthesize fetchBlock = _fetchBlock;

#pragma mark Initialization

+ (id)feedSource{
    return [[[[self class]alloc]init]autorelease];
}

-(void)postInit{
}

- (id)init {
	if (self = [super init]) {
		[self reset];
		[self postInit];
	}
	return self;
}

- (void)dealloc {
	_delegate = nil;
    [_fetchBlock release];
    _fetchBlock = nil;
	[super dealloc];
}

#pragma mark Public API

- (BOOL)fetchRange:(NSRange)theRange {
    if(self.isFetching || !self.hasMore)
        return NO;
    
	//self.hasMore = NO;
	self.range = theRange;
	self.isFetching = YES;
    
    if(self.fetchBlock){
        self.fetchBlock(self,theRange);
    }
    
	return YES;
}

- (void)cancelFetch {
	self.isFetching = NO;
	return;
}

- (void)reset {
	self.hasMore = YES;
	self.isFetching = NO;
}

#pragma mark KVO

- (void)addItems:(NSArray *)theItems {
	if(_delegate && [_delegate respondsToSelector:@selector(feedSource:didFetchItems:range:)]){
		[_delegate feedSource:self didFetchItems:theItems range:NSMakeRange(self.range.location, theItems.count)];
	}
	self.hasMore = (theItems.count >= self.range.length);
	self.isFetching = NO;
}

@end
