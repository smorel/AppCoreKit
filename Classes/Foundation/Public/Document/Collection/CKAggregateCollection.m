//
//  CKAggregateCollection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKAggregateCollection.h"
//#import "NSObject+Bindings.h"

@interface CKCollection()
@property (nonatomic,assign,readwrite) NSInteger count;
@property (nonatomic,assign,readwrite) BOOL isFetching;
@end

@interface CKArrayCollection()
@property (nonatomic,copy) NSMutableArray* collectionObjects;
@end

@implementation CKAggregateCollection{
    dispatch_queue_t _observerQueue;
}

@synthesize collections = _collections;

- (void)postInit{
    [super postInit];
    
    _observerQueue = dispatch_queue_create("com.appcorekit.CKAggregateCollection", NULL);
}

- (void)dealloc{
    dispatch_release(_observerQueue);
    
    if(_collections){
        for(CKCollection* collection in _collections){
            [collection removeObserver:self forKeyPath:@"isFetching"];
            [collection removeObserver:self];
        }
        [_collections release];
        _collections = nil;
    }
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
        if([collection isFetching]){
            return YES;
        }
    }
    return NO;
}

- (void)setCollections:(NSArray *)theCollections{
    if(_collections){
        for(CKCollection* collection in _collections){
            [collection removeObserver:self forKeyPath:@"isFetching"];
            [collection removeObserver:self];
        }
    }
    
    [_collections release];
    _collections = [theCollections retain];
    
    [self updateArray];
    
    BOOL bo = [self allCollections_isFetching];
    self.isFetching = bo;
    
    for(CKCollection* collection in _collections){
        [collection addObserver:self forKeyPath:@"isFetching" options:NSKeyValueObservingOptionNew context:nil];
        [collection addObserver:self];
    }
}

- (NSInteger)indexOffsetForCollection:(CKCollection*)collection{
    int count = 0;
    for(CKCollection* c in _collections){
        if(c == collection)
            return count;
        else{
            count += [c count];
        }
    }
    return count;
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    
    if([theKeyPath isEqualToString:@"isFetching"] && [self.collections indexOfObjectIdenticalTo:object] != NSNotFound){
        BOOL bo = [self allCollections_isFetching];
        self.isFetching = bo;
    }else if([theKeyPath isEqualToString:@"isFetching"] == NO){
        
        dispatch_sync(_observerQueue, ^{
            NSIndexSet* indexs = [change objectForKey:NSKeyValueChangeIndexesKey];
            NSArray *newModels = [change objectForKey: NSKeyValueChangeNewKey];
            
            NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
            
            NSInteger offset = [self indexOffsetForCollection:object];
            NSMutableIndexSet* offsetedIndexes = [NSMutableIndexSet indexSet];
            if(offset == 0){
                [offsetedIndexes addIndexes:indexs];
            }else{
                NSUInteger currentIndex = [indexs firstIndex];
                while (currentIndex != NSNotFound) {
                    [offsetedIndexes addIndex:offset+currentIndex];
                    currentIndex = [indexs indexGreaterThanIndex: currentIndex];
                }
            }
            
            switch(kind){
                case NSKeyValueChangeInsertion:{
                    [super insertObjects:newModels atIndexes:offsetedIndexes];
                    break;
                }
                case NSKeyValueChangeRemoval:{
                    [super removeObjectsAtIndexes:offsetedIndexes];
                    break;
                }
            }
        });
    }
    
    [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
}

//Forward to the non filtered collection

- (void)fetchRange:(NSRange)range{
	for(CKCollection* collection in _collections){
        [collection fetchRange:range];
    }
}

- (void)cancelFetch{
    for(CKCollection* collection in _collections){
        [collection cancelFetch];
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    NSAssert(NO,@"CKAggregateCollection insertObjects Not Supported! You must insert in the non aggregated collections directly.");
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
    NSAssert(NO,@"CKAggregateCollection removeObjectsAtIndexes Not Supported! You must insert in the non aggregated collections directly.");
}

- (void)removeAllObjects{
    NSAssert(NO,@"CKAggregateCollection removeAllObjects Not Supported! You must insert in the non aggregated collections directly.");
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
    NSAssert(NO,@"CKAggregateCollection replaceObjectAtIndex Not Supported! You must insert in the non aggregated collections directly.");
}

@end
