//
//  CKDocumentFilteredCollection.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentArray.h"

@interface CKDocumentFilteredCollection : CKDocumentArrayCollection
@property(nonatomic,retain)CKDocumentCollection* collection;
@property(nonatomic,retain)NSPredicate* predicate;

+ (CKDocumentFilteredCollection*)filteredCollectionWithCollection:(CKDocumentCollection*)collection usingPredicate:(NSPredicate*)predicate;
- (id)initWithCollection:(CKDocumentCollection*)collection usingPredicate:(NSPredicate*)predicate;

@end
