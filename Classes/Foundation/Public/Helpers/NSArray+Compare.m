//
//  NSArray+Compare.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/10/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "NSArray+Compare.h"

@implementation NSArray (Compare)

- (void)compareToArray:(NSArray*)other commonIndexSet:(NSMutableIndexSet**)commonIndexSet addedIndexSet:(NSMutableIndexSet**)addedIndexSet removedIndexSet:(NSMutableIndexSet**)removedIndexSet identicalTo:(BOOL)identicalTo{
    if(self == nil){
        if(!(*addedIndexSet)){ *addedIndexSet = [NSMutableIndexSet indexSet]; }
        [*addedIndexSet addIndexesInRange:NSMakeRange(0, other.count)];
        return;
    }
    
    if(!(*removedIndexSet)){ *removedIndexSet = [NSMutableIndexSet indexSet]; }
    if(!(*commonIndexSet)){ *commonIndexSet = [NSMutableIndexSet indexSet]; }
    
    NSInteger index = 0;
    for(id object in self){
        NSInteger indexInArray = identicalTo ? [other indexOfObjectIdenticalTo:object] : [other indexOfObject:object];
        if(indexInArray == NSNotFound){
            [*removedIndexSet addIndex:index];
        }else{
            [*commonIndexSet addIndex:index];
        }
        ++index;
    }
    
    if(!(*addedIndexSet)){ *addedIndexSet = [NSMutableIndexSet indexSet]; }
    
    index = 0;
    for(id object in other){
        NSInteger indexInArray = identicalTo ? [self indexOfObjectIdenticalTo:object] : [self indexOfObject:object];
        if(indexInArray == NSNotFound){
            [*addedIndexSet addIndex:index];
        }
        ++index;
    }

}

- (void)compareToArray:(NSArray*)other commonIndexSet:(NSMutableIndexSet**)commonIndexSet addedIndexSet:(NSMutableIndexSet**)addedIndexSet removedIndexSet:(NSMutableIndexSet**)removedIndexSet{
    [self compareToArray:other commonIndexSet:commonIndexSet addedIndexSet:addedIndexSet removedIndexSet:removedIndexSet identicalTo:YES];
}


@end
