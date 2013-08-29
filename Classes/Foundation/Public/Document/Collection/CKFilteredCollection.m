//
//  CKFilteredCollection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFilteredCollection.h"
#import "CKDebug.h"

typedef enum CKFilteredCollectionUpdateType{
    CKFilteredCollectionUpdateTypeReload,
    CKFilteredCollectionUpdateTypeInsertion,
    CKFilteredCollectionUpdateTypeRemoval
}CKFilteredCollectionUpdateType;

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
    _collection = [theCollection retain];
    [_collection addObserver:self];
    
    [self updateFilteredArray:CKFilteredCollectionUpdateTypeReload];
    
    BOOL bo = [theCollection isFetching];
    self.isFetching =  bo;
    
    return self;
}

- (void)compareArray:(NSArray*)source withArray:(NSArray*)target
          updateType:(CKFilteredCollectionUpdateType)updateType
    indexSetToRemove:(NSMutableIndexSet*)indexSetToRemove
     objectsToInsert:(NSMutableArray*)objectsToInsert
    indexSetToInsert:(NSMutableIndexSet*)indexSetToInsert{
    
    if(updateType == CKFilteredCollectionUpdateTypeReload){
        [indexSetToRemove addIndexesInRange:NSMakeRange(0,[source count])];
        [objectsToInsert addObjectsFromArray:target];
        [indexSetToInsert addIndexesInRange:NSMakeRange(0,[target count])];
    }else if(updateType == CKFilteredCollectionUpdateTypeRemoval){
        //Finds indexs to remove :
        int j=0;
        int i=0;
        for(;i<[source count];++i){
            id src_object = [source objectAtIndex:i];
            id target_object = [target objectAtIndex:j];
            if([src_object isEqual:target_object]){ ++j; }
            else{
                [indexSetToRemove addIndex:i];
            }
        }
        
        //CKAssert((i == [source count] && j == [target count]), @"PROBLEM !");
    }else if(updateType == CKFilteredCollectionUpdateTypeInsertion){
        //Finds indexs to insert :
        int j=0;
        int i=0;
        for(;j<[target count];++j){
            id target_object = [target objectAtIndex:j];
            if(j >= [source count]){
                [objectsToInsert addObject:target_object];
                [indexSetToInsert addIndex:j];
            }else{
                id src_object = [source objectAtIndex:i];
                if([src_object isEqual:target_object]){ ++i; }
                else{
                    [objectsToInsert addObject:target_object];
                    [indexSetToInsert addIndex:j];
                }
            }
        }
        
        //CKAssert((i == [source count] && j == [target count]), @"PROBLEM !");
    }
}

- (void)updateFilteredArray:(CKFilteredCollectionUpdateType)updateType{
    NSArray* filteredObjects = [[self.collection allObjects]filteredArrayUsingPredicate:self.predicate];
    if([filteredObjects isEqualToArray:[self allObjects]])
        return;
    
    NSArray* selfObjects = [self allObjects];

    NSMutableIndexSet* indexSetToRemove = [NSMutableIndexSet indexSet];
    NSMutableIndexSet* indexSetToInsert = [NSMutableIndexSet indexSet];
    NSMutableArray* objectsToInsert = [NSMutableArray array];
    [self compareArray:selfObjects withArray:filteredObjects updateType:updateType indexSetToRemove:indexSetToRemove objectsToInsert:objectsToInsert indexSetToInsert:indexSetToInsert];
    
    if([indexSetToRemove count] > 0){
        [super removeObjectsAtIndexes:indexSetToRemove];
    }
    if([indexSetToInsert count] > 0){
        [super insertObjects:objectsToInsert atIndexes:indexSetToInsert];
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
    NSAssert(NO,@"CKFilteredCollection removeObjectsAtIndexes Not Supported! You must insert in the non filtered collection directly.");
}

- (void)removeAllObjects{
    NSAssert(NO,@"CKFilteredCollection removeAllObjects Not Supported! You must insert in the non filtered collection directly.");
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
    NSAssert(NO,@"CKFilteredCollection replaceObjectAtIndex Not Supported! You must insert in the non filtered collection directly.");
}

@end
