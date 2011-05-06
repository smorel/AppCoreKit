//
//  CKObjectKeyValue.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"
#import "CKNSObject+Introspection.h"
#import "CKClassPropertyDescriptor.h"
#import "CKDocumentCollection.h"


@interface CKObjectProperty : CKModelObject {
}
@property (nonatomic,retain) id object;
@property (nonatomic,retain) NSString* keyPath;
@property (nonatomic,assign) id value;

- (id)initWithObject:(id)object keyPath:(NSString*)keyPath;

- (CKClassPropertyDescriptor*)descriptor;
- (id)value;
- (void)setValue:(id)value;

- (CKDocumentCollection*)editorCollectionWithFilter:(NSString*)filter;
- (Class)tableViewCellControllerType;

- (CKModelObjectPropertyMetaData*)metaData;

@end
