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


@interface CKObjectProperty : NSObject {
}
@property (nonatomic,retain) id object;
@property (nonatomic,retain) NSString* keyPath;
@property (nonatomic,assign) id value;
@property (nonatomic,readonly) NSString* name;

+ (CKObjectProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath;
- (id)initWithObject:(id)object keyPath:(NSString*)keyPath;

- (CKClassPropertyDescriptor*)descriptor;
- (CKModelObjectPropertyMetaData*)metaData;
- (id)value;
- (void)setValue:(id)value;
- (id)convertToClass:(Class)type;

//FIXME : for property grids. think to a good way to setup configuration for properties in generic controllers (see metaData)
- (CKDocumentCollection*)editorCollectionWithFilter:(NSString*)filter;
- (CKDocumentCollection*)editorCollectionForNewlyCreated;
- (Class)tableViewCellControllerType;

@end
