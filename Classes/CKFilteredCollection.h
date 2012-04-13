//
//  CKFilteredCollection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-12-08.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKArrayCollection.h"

@interface CKFilteredCollection : CKArrayCollection
@property(nonatomic,retain)CKCollection* collection;
@property(nonatomic,retain)NSPredicate* predicate;

+ (CKFilteredCollection*)filteredCollectionWithCollection:(CKCollection*)collection usingPredicate:(NSPredicate*)predicate;
- (id)initWithCollection:(CKCollection*)collection usingPredicate:(NSPredicate*)predicate;

@end
