//
//  NFBDocument.m
//  NFB
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocument.h"


@implementation CKDocument
@synthesize objects;
@synthesize onDiskStorageKeys;

- (id)init{
	[super init];
	self.objects = [NSMutableDictionary dictionary];
	return self;
}

- (void)dealloc{
	self.objects = nil;
	[super dealloc];
}

- (NSMutableArray*)objectsForKey:(NSString*)key{
	NSMutableArray* objectsForKey = [objects objectForKey:key];
	if(objectsForKey == nil){
		if(onDiskStorageKeys && [onDiskStorageKeys containsObject:key]){
			objectsForKey = [self loadObjectsForKey:key];
		}
		else{
			objectsForKey = [NSMutableArray array];
			[objects setObject:objectsForKey forKey:key];
		}
	}
	return objectsForKey;
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
	NSMutableArray* objectsForKey = [self objectsForKey:key];
	
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([objectsForKey count], [newItems count])];
    [self.objects willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:key];
    [objectsForKey addObjectsFromArray:newItems];
    [self.objects didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:key];	
	
	if(onDiskStorageKeys && [onDiskStorageKeys containsObject:key]){
		[self saveObjectsForKey:key];
	}
}

- (void)removeObjects:(NSArray*)items forKey:(NSString*)key{
}

@end
