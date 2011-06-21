//
//  CKDocumentStorage.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

@class CKDocumentCollection;
@protocol CKDocumentStorage

- (BOOL)load:(CKDocumentCollection*)collection;
- (BOOL)save:(CKDocumentCollection*)collection;

@end
