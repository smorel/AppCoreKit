//
//  CKFilteredCollection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFilteredCollection.h"
#import "CKDebug.h"
#import "NSArray+Compare.h"

typedef NS_ENUM(NSInteger, CKFilteredCollectionUpdateType){
    CKFilteredCollectionUpdateTypeReload,
    CKFilteredCollectionUpdateTypeInsertion,
    CKFilteredCollectionUpdateTypeRemoval
};

@interface CKCollection()
@property (nonatomic,assign,readwrite) NSInteger count;
@property (nonatomic,assign,readwrite) BOOL isFetching;
@end


@interface CKArrayCollection()
@property (nonatomic,copy) NSMutableArray* collectionObjects;
@end

@implementation CKFilteredCollection
@synthesize collection = _collection;
@synthesize predicate = _predicate;

- (void)postInit{
    [super postInit];
}

- (void)dealloc{
    if(_collection){
        [_collection removeObserver:self forKeyPath:@"isFetching"];
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
    _predicate = [thepredicate retain];
    self.collection = [theCollection retain];
    
    BOOL bo = [theCollection isFetching];
    self.isFetching =  bo;
    
    return self;
}

- (void)updateFilteredArray:(CKFilteredCollectionUpdateType)updateType{
    NSArray* filteredObjects = [[self.collection allObjects]filteredArrayUsingPredicate:self.predicate];
    if([filteredObjects isEqualToArray:[self allObjects]])
        return;

    NSMutableIndexSet* removed = nil;
    NSMutableIndexSet* added = nil;
    NSMutableIndexSet* common = nil;
    [[self allObjects]compareToArray:filteredObjects commonIndexSet:&common addedIndexSet:&added removedIndexSet:&removed];
    
    if([removed count] > 0){
        [super removeObjectsAtIndexes:removed];
    }
    if([added count] > 0){
        [super insertObjects:[filteredObjects objectsAtIndexes:added] atIndexes:added];
    }
}

- (void)setCollection:(CKCollection *)theCollection{
    if(_collection){
        [_collection removeObserver:self forKeyPath:@"isFetching"];
        [_collection removeObserver:self];
    }
    
    [_collection release];
    _collection = [theCollection retain];
    
    if(theCollection){
        [theCollection addObserver:self forKeyPath:@"isFetching" options:NSKeyValueObservingOptionNew context:nil];
        [theCollection addObserver:self];
    }
    
    [self updateFilteredArray:CKFilteredCollectionUpdateTypeReload];
}

- (void)setPredicate:(NSPredicate *)thepredicate{
    [_predicate release];
    _predicate = [thepredicate retain];
    
    [self updateFilteredArray:CKFilteredCollectionUpdateTypeReload];
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    
    if(object == self.collection && [theKeyPath isEqualToString:@"isFetching"]){
        BOOL bo = self.collection.isFetching;
        self.isFetching =  bo;
    }else if([theKeyPath isEqualToString:@"isFetching"] == NO){
        NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
    
        [self updateFilteredArray:(kind == NSKeyValueChangeInsertion) ? CKFilteredCollectionUpdateTypeInsertion : CKFilteredCollectionUpdateTypeRemoval];
    }
    
    [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
}

//Forward to the non filtered collection

- (void)fetchRange:(NSRange)range{
	[self.collection fetchRange:range];
}


- (void)cancelFetch{
    [self.collection cancelFetch];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    NSAssert(NO,@"CKFilteredCollection insertObjects Not Supported! You must insert in the non filtered collection directly.");
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
    NSArray* objects = [[self allObjects]objectsAtIndexes:indexSet];
    NSIndexSet* originalIndexes = [[self.collection allObjects]indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [objects indexOfObjectIdenticalTo:obj] != NSNotFound;
    }];
    
    [self.collection removeObjectsAtIndexes:originalIndexes];
}

- (void)removeAllObjects{
    [self removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.count)]];
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
    NSAssert(NO,@"CKFilteredCollection replaceObjectAtIndex Not Supported! You must insert in the non filtered collection directly.");
}

@end
