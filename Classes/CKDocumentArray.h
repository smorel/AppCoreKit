//
//  CKDocumentArray.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentCollection.h"


@interface CKDocumentArray : CKDocumentCollection {
	NSMutableArray* _objects;
}

@end
