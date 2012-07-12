//
//  CKArrayCollection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKArrayCollection.h"

@interface CKArrayCollection()
@property (nonatomic,copy) NSMutableArray* collectionObjects;
@end

@implementation CKArrayCollection {
	NSMutableArray* _collectionObjects;
}

@synthesize collectionObjects = _collectionObjects;

- (void)postInit{
	[super postInit];
    self.collectionObjects = [NSMutableArray array];
	self.property = [CKProperty propertyWithObject:self keyPath:@"collectionObjects"];
}

- (void)setObjects:(NSMutableArray *)theobjects{
    [_collectionObjects release];
    _collectionObjects = [[NSMutableArray arrayWithArray:theobjects]retain];
	self.property = [CKProperty propertyWithObject:self keyPath:@"collectionObjects"];
}

- (void)setCollectionObjects:(NSMutableArray *)collectionObjects{
    [_collectionObjects release];
    _collectionObjects = [collectionObjects mutableCopy];
}

- (id) copyWithZone:(NSZone *)zone {
    CKArrayCollection* collection = [super copyWithZone:zone];
    collection.property = [CKProperty propertyWithObject:collection keyPath:@"collectionObjects"];
    return collection;
}

- (void)insertCollectionObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    [self.collectionObjects insertObjects:objects atIndexes:indexes];
}

- (void)removeCollectionObjectsAtIndexes:(NSIndexSet *)indexes{
    [self.collectionObjects removeObjectsAtIndexes:indexes];
}

- (void)dealloc {
    [_collectionObjects release];
    self.property = nil;
    
    [super dealloc];
}

@end
