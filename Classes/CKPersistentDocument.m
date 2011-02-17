//
//  CKPersistentDocument.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPersistentDocument.h"

@interface CKPersistentDocument ()
- (void)saveObjectsForKey:(NSString*)key;
- (NSMutableArray*)loadObjectsForKey:(NSString*)key;
@end

@implementation CKPersistentDocument
@synthesize objects;
@synthesize persistentKeys;
@synthesize autoSave;

- (id)init{
	[super init];
	self.objects = [NSMutableDictionary dictionary];
	autoSave = NO;
	return self;
}

- (void)dealloc{
	self.objects = nil;
	[super dealloc];
}

- (NSMutableArray*)mutableObjectsForKey:(NSString*)key{
	NSMutableArray* objectsForKey = [objects objectForKey:key];
	if(objectsForKey == nil){
		if(persistentKeys && [persistentKeys containsObject:key]){
			objectsForKey = [self loadObjectsForKey:key];
		}
		else{
			objectsForKey = [NSMutableArray array];
			[objects setObject:objectsForKey forKey:key];
		}
	}
	return objectsForKey;
}

- (NSArray*)objectsForKey:(NSString*)key{
	return [self mutableObjectsForKey:key];
}

- (void)saveObjectsForKey:(NSString*)key{
	NSMutableArray* objectsForKey = [objects objectForKey:key];
	if(objectsForKey){
		NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive",key]];
		BOOL result = [NSKeyedArchiver archiveRootObject:objectsForKey toFile:archivePath];
		NSAssert(result,@"Unable to save objects for key %@ in %@",key,archivePath);
	}
	else{
		NSAssert(NO,@"Document try to save unexistant objects %@",key);
	}
}

- (NSMutableArray*)loadObjectsForKey:(NSString*)key{
	NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive",key]];
	BOOL bo = [[NSFileManager defaultManager] fileExistsAtPath:archivePath];
	
	NSMutableArray* objectsForKey = nil;
	if(bo){
		id result = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
		NSAssert(result && [result isKindOfClass:[NSMutableArray class]],@"error when loading objects for key %@ in %@",key,archivePath);
		objectsForKey = (NSMutableArray*)result;
	}
	else{
		objectsForKey = [NSMutableArray array];
	}
	[objects setObject:objectsForKey forKey:key];
	return objectsForKey;
}

- (void)addObjects:(NSArray*)newItems forKey:(NSString*)key{
	NSMutableArray* objectsForKey = [self mutableObjectsForKey:key];
	
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([objectsForKey count], [newItems count])];
    [self.objects willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:key];
    [objectsForKey addObjectsFromArray:newItems];
    [self.objects didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:key];	
	
	if(autoSave && persistentKeys && [persistentKeys containsObject:key]){
		[self saveObjectsForKey:key];
	}
}

- (void)save{
	for(NSString* key in persistentKeys){
		[self saveObjectsForKey:key];
	}
}

- (void)removeObjects:(NSArray*)items forKey:(NSString*)key{
	NSMutableArray* objectsForKey = [self mutableObjectsForKey:key];  
	
	NSMutableArray* toRemove = [NSMutableArray array];
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	for(id item in items){
		NSUInteger index = [objectsForKey indexOfObject:item];
		if(index == NSNotFound){
			NSLog(@"invalid object when remove");
		}
		else{
			[indexSet addIndex:index];
			[toRemove addObject:item];
		}
	}
	
	[self.objects willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:key];
	[objectsForKey removeObjectsInArray:toRemove];
	[self.objects didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:key];
}

- (void)addObserver:(id)object forKey:(NSString*)key{
	[self.objects addObserver:object forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)removeObserver:(id)object forKey:(NSString*)key{
	[self.objects removeObserver:object forKeyPath:key];	
}

@end
