//
//  CKFilteredCollection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFilteredCollection.h"
#import "NSObject+Bindings.h"

@interface CKCollection()
@property (nonatomic,assign,readwrite) BOOL isFetching;
@end

@implementation CKFilteredCollection
@synthesize collection = _collection;
@synthesize predicate = _predicate;

- (void)postInit{
    [super postInit];
}

- (void)dealloc{
    if(_collection){
        [_collection removeObserver:self];
        [_collection release];
        _collection = nil;
    }
    [_predicate release];
    _predicate = nil;
    [super dealloc];
}


+ (CKFilteredCollection*)filteredCollectionWithCollection:(CKCollection*)collection usingPredicate:(NSPredicate*)predicate{
    return [[[CKFilteredCollection alloc]initWithCollection:collection usingPredicate:predicate]autorelease];
}

- (id)initWithCollection:(CKCollection*)theCollection  usingPredicate:(NSPredicate*)thepredicate{
    self = [super init];
    self.predicate = thepredicate;
    self.collection = theCollection;
    
    [self updateFilteredArray];
    
    BOOL bo = [theCollection isFetching];
    self.isFetching =  bo;
    
    __block CKFilteredCollection* bself = self;
    [self beginBindingsContextByRemovingPreviousBindings];
    [theCollection bind:@"isFetching" withBlock:^(id value) {
        BOOL bo = [value boolValue];
        bself.isFetching =  bo;
    }];
    [self endBindingsContext];
    
    
    return self;
}

- (void)updateFilteredArray{
    NSArray* filteredObjects = [[self.collection allObjects]filteredArrayUsingPredicate:self.predicate];
    if([filteredObjects isEqualToArray:[self allObjects]])
        return;
    
    [super removeAllObjects];
    [super insertObjects:filteredObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self count], [filteredObjects count])]];
}

- (void)setCollection:(CKCollection *)theCollection{
    if(_collection){
        [_collection removeObserver:self];
    }
    
    [_collection release];
    _collection = [theCollection retain];
    
    [_collection addObserver:self];
    
    [self updateFilteredArray];
}

- (void)setPredicate:(NSPredicate *)thepredicate{
    [_predicate release];
    _predicate = [thepredicate retain];
    
    [self updateFilteredArray];
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    
    //THIS COULD BE OPTIMIZED !!!!
    [self updateFilteredArray];
}

//Forward to the non filtered collection

- (void)fetchRange:(NSRange)range{
	[self.collection fetchRange:range];
}

- (NSIndexSet*)filteredIndexSet:(NSIndexSet*)indexes{
    NSMutableIndexSet* nonFilteredIndexPaths = [NSMutableIndexSet indexSet];
    
	unsigned currentIndex = [indexes firstIndex];
	while (currentIndex != NSNotFound) {
        if(currentIndex >= [self count]){
            [nonFilteredIndexPaths addIndex:currentIndex];
        }
        else{
            id currentObject = [self objectAtIndex:currentIndex];
            NSInteger index = [[self.collection allObjects]indexOfObjectIdenticalTo:currentObject];
            NSAssert(index != NSNotFound,@"Should not happend !");
            [nonFilteredIndexPaths addIndex:index];
        }
        currentIndex = [indexes indexGreaterThanIndex: currentIndex];
	}
    return nonFilteredIndexPaths;
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    [self.collection insertObjects:objects atIndexes:[self filteredIndexSet:indexes]];
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
    [self.collection removeObjectsAtIndexes:[self filteredIndexSet:indexSet]];
}

- (void)removeAllObjects{
	[self.collection removeAllObjects];
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
	id currentObject = [self objectAtIndex:index];
    NSInteger theIndex = [[self.collection allObjects]indexOfObjectIdenticalTo:currentObject];
    [self.collection replaceObjectAtIndex:theIndex byObject:other];
}

/* TODO find a way for CKItamViewContainerController to work with collectionDataSource ...
 - (CKFeedSource*)feedSource{
 return self.collection.feedSource;
 }
 */


@end
