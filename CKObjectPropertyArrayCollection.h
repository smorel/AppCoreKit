//
//  CKObjectPropertyArrayCollection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentCollection.h"
#import "CKObjectProperty.h"


@interface CKObjectPropertyArrayCollection : CKDocumentCollection {
	CKObjectProperty* _property;
}

@property (nonatomic,retain) CKObjectProperty* property;

+ (CKObjectPropertyArrayCollection*)collectionWithArrayProperty:(CKObjectProperty*)property;

- (id)initWithArrayProperty:(CKObjectProperty*)property;

@end
