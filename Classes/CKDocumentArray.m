//
//  CKDocumentArray.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentArray.h"

@interface CKDocumentArray()
@property (nonatomic,retain) NSMutableArray* objects;
@end

@implementation CKDocumentArray
@synthesize objects = _objects;

- (void)objectsMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.creatable = YES;
}

- (NSInteger)count{
	return [_objects count];
}

- (id)objectAtIndex:(NSInteger)index{
	return [_objects objectAtIndex:index];
}

- (void)addObjectsFromArray:(NSArray *)otherArray{
	[self insertObjects:otherArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([_objects count], [otherArray count])]];
}

- (void)insertObjects:(NSArray *)theObjects atIndexes:(NSIndexSet *)indexes{
	if([theObjects count] <= 0)
		return;
	
    //NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [newItems count])];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"objects"];
    [_objects insertObjects:theObjects atIndexes:indexes];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"objects"];	
	
	if(self.autosave){
		[self save];
	}
}

- (void)removeObjectsInArray:(NSArray *)otherArray{
	NSMutableArray* toRemove = [NSMutableArray array];
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	for(id item in otherArray){
		NSUInteger index = [_objects indexOfObject:item];
		if(index == NSNotFound){
			NSLog(@"invalid object when remove");
		}
		else{
			[indexSet addIndex:index];
			[toRemove addObject:item];
		}
	}
	
	if([toRemove count] <= 0)
		return;
	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"objects"];
	[_objects removeObjectsInArray:toRemove];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"objects"];
	
	if(self.autosave){
		[self save];
	}	
}

- (void)removeAllObjects{
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[_objects count])];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"objects"];
	[_objects removeAllObjects];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"objects"];
	
	if(self.autosave){
		[self save];
	}
}

- (void)addObserver:(id)object{
	[self addObserver:object forKeyPath:@"objects" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)removeObserver:(id)object{
	[self removeObserver:object forKeyPath:@"objects"];
}

@end
