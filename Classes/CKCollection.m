//
//  CKCollection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollection.h"
#import "NSObject+Invocation.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import "NSObject+Bindings.h"
#import "CKDebug.h"

@interface CKCollection()
@property (nonatomic,assign,readwrite) NSInteger count;
@property (nonatomic,assign,readwrite) BOOL isFetching;
@end

@implementation CKCollection{
	CKFeedSource* _feedSource;
	id _delegate;
	NSInteger _count;
}

@synthesize feedSource = _feedSource;
@synthesize delegate = _delegate;
@synthesize count = _count;
@synthesize isFetching = _isFetching;

@synthesize addObjectsBlock = _addObjectsBlock;
@synthesize removeObjectsBlock = _removeObjectsBlock;
@synthesize replaceObjectBlock = _replaceObjectBlock;
@synthesize clearBlock = _clearBlock;
@synthesize startFetchingBlock = _startFetchingBlock;
@synthesize endFetchingBlock = _endFetchingBlock;

- (void)postInit{
	_count = 0;
    _isFetching = NO;
}

- (id)init{
	if (self = [super init]) {
        [self postInit];
    }
	return self;
}

- (void)dealloc{
    [self clearBindingsContext];
    
    if(_feedSource){
        _feedSource.delegate = nil;
        [_feedSource cancelFetch];
    }
    [_feedSource release];
    _feedSource = nil;
    [_addObjectsBlock release];
    _addObjectsBlock = nil;
    [_removeObjectsBlock release];
    _removeObjectsBlock = nil;
    [_replaceObjectBlock release];
    _replaceObjectBlock = nil;
    [_clearBlock release];
    _clearBlock = nil;
    [_startFetchingBlock release];
    _startFetchingBlock = nil;
    [_endFetchingBlock release];
    _endFetchingBlock = nil;
    [super dealloc];
}


+ (id)collection{
	return [[[[self class]alloc]init]autorelease];
}

+ (id)collectionWithFeedSource:(CKFeedSource*)source{
    return [[[[self class]alloc]initWithFeedSource:source]autorelease];
}

+ (id)collectionWithObjectsFromArray:(NSArray*)array{
    return [[[[self class]alloc]initWithObjectsFromArray:array]autorelease];
}

- (id)initWithFeedSource:(CKFeedSource*)source{
	if (self = [super init]) {
        self.feedSource = source;
        [self postInit];
    }
	return self;
}

- (id)initWithObjectsFromArray:(NSArray*)array{
    if (self = [super init]) {
        [self postInit];
        [self addObjectsFromArray:array];
    }
	return self;
}

- (void)setFeedSource:(CKFeedSource *)thefeedSource{
    if(_feedSource){
        _feedSource.delegate = nil;
        [_feedSource cancelFetch];
        [_feedSource release];
    }
    
    _feedSource = [thefeedSource retain];
	_feedSource.delegate = self;
    
    if(_feedSource){
        BOOL bo = [_feedSource isFetching];
        self.isFetching =  bo;
        
        __block CKCollection* bself = self;
        [self beginBindingsContextByRemovingPreviousBindings];
        [_feedSource bind:@"isFetching" withBlock:^(id value) {
            BOOL bo = [value boolValue];
            bself.isFetching =  bo;
        }];
        [self endBindingsContext];
    }
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
	CKAssert(NO,@"Abstract Implementation");
	return nil;
}

- (id)objectAtIndex:(NSInteger)index{
	CKAssert(NO,@"Abstract Implementation");
	return nil;
}

- (void)addObject:(id)object{
    [self addObjectsFromArray:[NSArray arrayWithObject:object]];
}

- (void)addObjectsFromArray:(NSArray *)otherArray{
	[self insertObjects:otherArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self count], [otherArray count])]];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
	CKAssert(NO,@"Abstract Implementation");
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
	CKAssert(NO,@"Abstract Implementation");
}

- (void)removeAllObjects{
	CKAssert(NO,@"Abstract Implementation");
}


- (void)addObserver:(id)object{
	CKAssert(NO,@"Abstract Implementation");
}

- (void)removeObserver:(id)object{
	CKAssert(NO,@"Abstract Implementation");
}

- (NSArray*)objectsMatchingPredicate:(NSPredicate*)predicate{
	CKAssert(NO,@"Abstract Implementation");
	return nil;
}

- (BOOL)containsObject:(id)object{
	CKAssert(NO,@"Abstract Implementation");
	return NO;
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
	CKAssert(NO,@"Abstract Implementation");
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

- (void)cancelFetch{
    if(_feedSource == nil)
		return;
    [_feedSource cancelFetch];
}

- (void)feedSource:(CKFeedSource *)feedSource didFetchItems:(NSArray *)items range:(NSRange)range{
	CKAssert(feedSource == _feedSource,@"Not registered on the right feedSource");
	
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
	CKAssert(feedSource == _feedSource,@"Not registered on the right feedSource");

	if (_delegate && [_delegate respondsToSelector:@selector(documentCollection:fetchDidFailWithError:)]) {
		[_delegate documentCollection:self fetchDidFailWithError:error];
	}
}


- (id) copyWithZone:(NSZone *)zone{
	id copied = [[[self class] allocWithZone:zone] init];
    [copied copyPropertiesFromObject:self];
	return copied;
}

/*
- (void)setCount:(NSInteger)c{
	[self willChangeValueForKey:@"count"];
    _count = c;
    [self didChangeValueForKey:@"count"];
}
 */

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len{
    return [[self allObjects]countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
