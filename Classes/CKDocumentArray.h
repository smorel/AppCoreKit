//
//  CKDocumentArray.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectPropertyArrayCollection.h"


/** TODO
 */
@interface CKDocumentArray : CKObjectPropertyArrayCollection {
	NSMutableArray* _objects;
}

@end
