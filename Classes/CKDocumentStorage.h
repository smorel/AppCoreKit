//
//  CKDocumentStorage.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKDocumentCollection;


/** TODO
 */
@protocol CKDocumentStorage

- (BOOL)load:(CKDocumentCollection*)collection;
- (BOOL)save:(CKDocumentCollection*)collection;

@end
