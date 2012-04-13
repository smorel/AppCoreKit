//
//  CKCollection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollection.h"
#import "CKNSObject+Invocation.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"


@implementation CKCollection
@synthesize feedSource = _feedSource;
@synthesize delegate = _delegate;
@synthesize count = _count;

@synthesize addObjectsBlock;
@synthesize removeObjectsBlock;
@synthesize replaceObjectBlock;
@synthesize clearBlock;
@synthesize startFetchingBlock;
@synthesize endFetchingBlock;

- (id)init{
	[super init];
	self.count = 0;
	return self;
}


- (id)initWithFeedSource:(CKFeedSource*)source{
	[super init];
	self.feedSource = source;
	return self;
}

- (void)setFeedSource:(CKFeedSource *)thefeedSource{
    if(_feedSource){
        _feedSource.delegate = nil;
        [_feedSource release];
    }
    
    _feedSource = [thefeedSource retain];
	_feedSource.delegate = self;
}

- (void)setDelegate:(id)thedelegate{
    _delegate = thedelegate;
}

- (void)feedSourceExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.serializable = NO;
}

- (void)delegateExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.serializable = NO;
	attributes.comparable = NO;
	attributes.hashable = NO;
}

- (NSArray*)allObjects{
	NSAssert(NO,@"Abstract Implementation");
	return nil;
}

- (id)objectAtIndex:(NSInteger)index{
	NSAssert(NO,@"Abstract Implementation");
	return nil;
}

- (void)addObject:(id)object{
    [self addObjectsFromArray:[NSArray arrayWithObject:object]];
}

- (void)addObjectsFromArray:(NSArray *)otherArray{
	[self insertObjects:otherArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self count], [otherArray count])]];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)removeAllObjects{
	NSAssert(NO,@"Abstract Implementation");
}


- (void)addObserver:(id)object{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)removeObserver:(id)object{
	NSAssert(NO,@"Abstract Implementation");
}

- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate{
	NSAssert(NO,@"Abstract Implementation");
	return nil;
}

- (BOOL)containsObject:(id)object{
	NSAssert(NO,@"Abstract Implementation");
	return NO;
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
	NSAssert(NO,@"Abstract Implementation");
}

- (void)fetchRange:(NSRange)range{
	if(_feedSource == nil)
		return;
	//adjust range to existing objects
	NSInteger requested = range.location + range.length;
	if(requested > self.count){
		[_feedSource fetchRange:NSMakeRange(self.count, requested - self.count)];
        
        if(self.startFetchingBlock){
            self.startFetchingBlock(range);
        }
	}
}

- (void)feedSource:(CKFeedSource *)feedSource didFetchItems:(NSArray *)items range:(NSRange)range{
	NSAssert(feedSource == _feedSource,@"Not registered on the right feedSource");
	
	//execute on main thread !
	//[self performSelectorOnMainThread:@selector(insertObjects:atIndexes:) withObject:items withObject:[NSIndexSet indexSetWithIndexesInRange:range] waitUntilDone:NO];
	[self insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];

	if (_delegate && [_delegate respondsToSelector:@selector(documentCollection:didFetchItems:atRange:)]) {
		[_delegate documentCollection:self didFetchItems:items atRange:range];
	}
    
    if(self.endFetchingBlock){
        self.endFetchingBlock(items,[NSIndexSet indexSetWithIndexesInRange:range]);
    }
}

- (void)feedSource:(CKFeedSource *)feedSource didFailWithError:(NSError *)error {
	NSAssert(feedSource == _feedSource,@"Not registered on the right feedSource");

	if (_delegate && [_delegate respondsToSelector:@selector(documentCollection:fetchDidFailWithError:)]) {
		[_delegate documentCollection:self fetchDidFailWithError:error];
	}
}

/*
- (void)setCount:(NSInteger)c{
	[self willChangeValueForKey:@"count"];
    _count = c;
    [self didChangeValueForKey:@"count"];
}
 */

@end
