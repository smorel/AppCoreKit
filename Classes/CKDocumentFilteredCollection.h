//
//  CKDocumentFilteredCollection.h
//  YellowPages
//
//  Created by Sebastien Morel on 11-12-08.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentArray.h"

@interface CKDocumentFilteredCollection : CKDocumentArrayCollection
@property(nonatomic,retain)CKCollection* collection;
@property(nonatomic,retain)NSPredicate* predicate;

+ (CKDocumentFilteredCollection*)filteredCollectionWithCollection:(CKCollection*)collection usingPredicate:(NSPredicate*)predicate;
- (id)initWithCollection:(CKCollection*)collection usingPredicate:(NSPredicate*)predicate;

@end
