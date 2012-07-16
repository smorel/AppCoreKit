//
//  CKDocumentArray.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectPropertyArrayCollection.h"


/** TODO
 */
@interface CKDocumentArrayCollection : CKObjectPropertyArrayCollection {
	NSMutableArray* _collectionObjects;
}

@end

//DEPRECATED_IN_CLOUDKIT_1.7
@interface CKDocumentArray : CKDocumentArrayCollection{}
@end