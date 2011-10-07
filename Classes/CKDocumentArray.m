//
//  CKDocumentArray.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentArray.h"
#import "CKNSNotificationCenter+Edition.h"

@interface CKDocumentArrayCollection()
@property (nonatomic,copy) NSMutableArray* collectionObjects;
@end

@implementation CKDocumentArrayCollection
@synthesize collectionObjects = _collectionObjects;

- (void)postInit{
	[super postInit];
    self.collectionObjects = [NSMutableArray array];
	self.property = [CKObjectProperty propertyWithObject:self keyPath:@"collectionObjects"];
}

- (void)setObjects:(NSMutableArray *)theobjects{
    [_collectionObjects release];
    _collectionObjects = [[NSMutableArray arrayWithArray:theobjects]retain];
	self.property = [CKObjectProperty propertyWithObject:self keyPath:@"collectionObjects"];
}

- (void)setCollectionObjects:(NSMutableArray *)collectionObjects{
    [_collectionObjects release];
    _collectionObjects = [[NSMutableArray arrayWithArray:[collectionObjects copy]]retain];
}

- (id) copyWithZone:(NSZone *)zone {
    CKDocumentArrayCollection* collection = [super copyWithZone:zone];
    collection.property = [CKObjectProperty propertyWithObject:collection keyPath:@"collectionObjects"];
    return collection;
}

- (void)insertCollectionObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    [self.collectionObjects insertObjects:objects atIndexes:indexes];
}

- (void)removeCollectionObjectsAtIndexes:(NSIndexSet *)indexes{
    [self.collectionObjects removeObjectsAtIndexes:indexes];
}

@end

@implementation CKDocumentArray
@end
