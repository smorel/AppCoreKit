//
//  CKDocumentArray.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentArray.h"
#import "CKNSNotificationCenter+Edition.h"

@interface CKDocumentArray()
@property (nonatomic,retain) NSMutableArray* objects;
@end

@implementation CKDocumentArray
@synthesize objects = _objects;

- (void)setObjects:(NSMutableArray*)array{
	//explicitely Make a clone
	[_objects release];
	_objects = [[NSMutableArray arrayWithArray:array]retain];
}


- (void)objectsMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.creatable = YES;
	
	//deepCopy + retain will make the array to duplicate all the objects from the source
	metaData.deepCopy = YES;
}

- (NSArray*)allObjects{
	return [NSArray arrayWithArray:_objects];
}

- (id)objectAtIndex:(NSInteger)index{
	return [_objects objectAtIndex:index];
}

- (void)insertObjects:(NSArray *)theObjects atIndexes:(NSIndexSet *)indexes{
	if([theObjects count] <= 0)
		return;
	
    [_objects insertObjects:theObjects atIndexes:indexes];
	self.count = [_objects count];
	
	[[NSNotificationCenter defaultCenter]notifyObjectsAdded:theObjects atIndexes:indexes inCollection:self];
	if(self.autosave){
		[self save];
	}
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
	NSArray* toRemove = [_objects objectsAtIndexes:indexSet];
	
	[_objects removeObjectsAtIndexes:indexSet];
	self.count = [_objects count];
	
	[[NSNotificationCenter defaultCenter]notifyObjectsRemoved:toRemove atIndexes:indexSet inCollection:self];
	
	if(self.autosave){
		[self save];
	}	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
}

- (void)removeAllObjects{
	NSArray* theObjects = [NSArray arrayWithArray: _objects];
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[_objects count])];
	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"objects"];
	[_objects removeAllObjects];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"objects"];
	self.count = [_objects count];
	
	[[NSNotificationCenter defaultCenter]notifyObjectsRemoved:theObjects atIndexes:indexSet inCollection:self];
	
	if(self.autosave){
		[self save];
	}
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
}

- (BOOL)containsObject:(id)object{
	return [_objects containsObject:object];
}

- (void)addObserver:(id)object{
	[self addObserver:object forKeyPath:@"objects" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)removeObserver:(id)object{
	[self removeObserver:object forKeyPath:@"objects"];
}

- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate{
	return [_objects filteredArrayUsingPredicate:predicate];
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
	id object = [_objects objectAtIndex:index];
	[_objects removeObjectAtIndex:index];
	[_objects insertObject:other atIndex:index];	
	
	[[NSNotificationCenter defaultCenter]notifyObjectReplaced:object byObject:other atIndex:index inCollection:self];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
}

@end
