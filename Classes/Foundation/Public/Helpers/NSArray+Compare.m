//
//  NSArray+Compare.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/10/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "NSArray+Compare.h"

@implementation NSArray (Compare)

- (void)compareToArray:(NSArray*)other addedIndexSet:(NSMutableIndexSet**)addedIndexSet removedIndexSet:(NSMutableIndexSet**)removedIndexSet{
    if(self == nil){
        if(!(*addedIndexSet)){ *addedIndexSet = [NSMutableIndexSet indexSet]; }
        [*addedIndexSet addIndexesInRange:NSMakeRange(0, other.count)];
        return;
    }
    
    if(!(*removedIndexSet)){ *removedIndexSet = [NSMutableIndexSet indexSet]; }
    
    NSInteger index = 0;
    for(id object in self){
        if([other indexOfObject:object] == NSNotFound){
            [*removedIndexSet addIndex:index];
        }
        ++index;
    }
    
    if(!(*addedIndexSet)){ *addedIndexSet = [NSMutableIndexSet indexSet]; }
    
    index = 0;
    for(id object in other){
        if([self indexOfObject:object] == NSNotFound){
            [*addedIndexSet addIndex:index];
        }
        ++index;
    }
}


@end
