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
@property (nonatomic,copy) NSMutableArray* objects;
@end

@implementation CKDocumentArrayCollection
@synthesize objects = _objects;

- (void)postInit{
	[super postInit];
    self.objects = [NSMutableArray array];
	self.property = [CKObjectProperty propertyWithObject:self keyPath:@"objects"];
}

- (void)setObjects:(NSMutableArray *)theobjects{
    [_objects release];
    _objects = [[NSMutableArray arrayWithArray:theobjects]retain];
	self.property = [CKObjectProperty propertyWithObject:self keyPath:@"objects"];
}

- (id) copyWithZone:(NSZone *)zone {
    CKDocumentArrayCollection* collection = [super copyWithZone:zone];
    collection.property = [CKObjectProperty propertyWithObject:collection keyPath:@"objects"];
    return collection;
}

@end

@implementation CKDocumentArray
@end
