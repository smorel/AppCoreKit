//
//  CKAggregateCollection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-12-08.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKArrayCollection.h"

@interface CKAggregateCollection : CKArrayCollection
@property(nonatomic,retain)NSArray* collections;

+ (CKAggregateCollection*)aggregateCollectionWithCollections:(NSArray*)collections;
- (id)initWithCollections:(NSArray*)collections;

@end
