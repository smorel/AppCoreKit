//
//  CKAggregateCollection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-12-08.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKAggregateCollection.h"
#import "CKNSObject+Bindings.h"

@interface CKCollection()
@property (nonatomic,assign,readwrite) NSInteger count;
@property (nonatomic,assign,readwrite) BOOL isFetching;
@end

@implementation CKAggregateCollection
@synthesize collections = _collections;

- (void)postInit{
    [super postInit];
}

- (void)dealloc{
    if(_collections){
        for(CKCollection* collection in _collections){
            [collection removeObserver:self];
        }
    }
    //Do not release objects as collections inherits CKObject
    [super dealloc];
}

+ (CKAggregateCollection*)aggregateCollectionWithCollections:(NSArray*)collections{
    return [[[CKAggregateCollection alloc]initWithCollections:collections]autorelease];
}

- (id)initWithCollections:(NSArray*)thecollections{
    self = [super init];
    self.collections = thecollections;
    return self; 
}

- (void)updateArray{
    NSMutableArray* array = [NSMutableArray array];
    for(CKCollection* collection in _collections){
        [array addObjectsFromArray:[collection allObjects]];
    }
    
    [super removeAllObjects];
    [super insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self count], [array count])]];
}

- (BOOL)allCollections_isFetching{
    for(CKCollection* collection in _collections){
        if([collection isFetching])
            return YES;
    }
    return NO;
}

- (void)setCollections:(NSArray *)theCollections{
    if(_collections){
        for(CKCollection* collection in _collections){
            [collection removeObserver:self];
        }
    }
    
    [_collections release];
    _collections = [theCollections retain];
    
    __block CKAggregateCollection* bself = self;
    [self beginBindingsContextByRemovingPreviousBindings];
    for(CKCollection* collection in _collections){
        [collection addObserver:self];
        [collection bind:@"isFetching" withBlock:^(id value){
            BOOL bo = [bself allCollections_isFetching];
            if(bo != self.isFetching){
                self.isFetching = bo;
            }
        }];
    }
    [self endBindingsContext];
    
    [self updateArray];
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    
    //THIS COULD BE OPTIMIZED !!!!
    [self updateArray];
}

//Forward to the non filtered collection

- (void)fetchRange:(NSRange)range{
	//TODO ! TO IMPLEMENT
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    [self updateArray];//THIS COULD BE OPTIMIZED !!!!
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
    [self updateArray];//THIS COULD BE OPTIMIZED !!!!
}

- (void)removeAllObjects{
    [self updateArray];//THIS COULD BE OPTIMIZED !!!!
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
    [self updateArray];//THIS COULD BE OPTIMIZED !!!!
}

/* TODO find a way for CKItamViewContainerController to work with collectionDataSource ...
 - (CKFeedSource*)feedSource{
 return self.collection.feedSource;
 }
 */


@end
