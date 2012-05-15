//
//  CKGridCollection.m
//  CloudKit
//
//  Created by Martin Dufort on 12-05-14.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKGridCollection.h"

@interface CKGridCollection()
- (void)updateArray;
@end

@implementation CKGridCollection
@synthesize collection = _collection;
@synthesize size = _size;

- (void)dealloc{
    [_collection dealloc];
    [super dealloc];
}

- (id)initWithCollection:(CKCollection*)theCollection size:(CGSize)theSize{
    self = [super init];
    
    _size = theSize;
    self.collection = theCollection;//this listen collection and update internal array
    
    return self;
}

- (void)setCollection:(CKCollection *)theCollection{
    if(_collection){
        [_collection removeObserver:self];
    }
    
    [_collection release];
    _collection = [theCollection retain];
    
    [_collection addObserver:self];
    
    [self updateArray];
}

- (void)setSize:(CGSize)theSize{
    _size = theSize;
    [self updateArray];
}


- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    
    //THIS COULD BE OPTIMIZED !!!!
    [self updateArray];
}

- (void)updateArray{
    NSMutableArray* objects = [NSMutableArray array];
    
    int i =0;
    NSMutableArray* currentArray = nil;
    for(id object in [self.collection allObjects]){
        if(i == 0){
            currentArray = [NSMutableArray array];
            [objects addObject:currentArray];
        }
        
        [currentArray addObject:object];
        
        ++i;
        
        if(i >= _size.height){
            i = 0;
        }
    }
    
    /*
    if([self count] > [objects count]){
        [self removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([objects count], [self count] - [objects count])]];
    }
    
    for(int i = 0;i < [objects count]; ++i){
        NSArray* array = [objects objectAtIndex:i];
        if([self count] > i){
            NSArray* originalArray = [self objectAtIndex:i];
            if(![originalArray isEqualToArray:array]){
                [self replaceObjectAtIndex:i byObject:array];
            }
        }else{
            NSArray* subset = [objects subarrayWithRange:NSMakeRange(i, [objects count] - i)];
            [self addObjectsFromArray:subset];
            break;
        }
    }
     */
    
    [self removeAllObjects];
    [self addObjectsFromArray:objects];
}

- (void)fetchRange:(NSRange)range{
    [self.collection fetchRange:NSMakeRange(range.location * _size.height, range.length * _size.height)];
}

@end
