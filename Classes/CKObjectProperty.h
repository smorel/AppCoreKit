//
//  CKObjectKeyValue.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSObject+Introspection.h"
#import "CKClassPropertyDescriptor.h"
#import "CKObjectPropertyMetaData.h"

//FIXME : try to remove this dependencies by making a CKObjectProperty+CKDocument extension
#import <MapKit/MapKit.h>
#import "CKDocumentCollection.h"

/** TODO
 */
@interface CKObjectProperty : NSObject {
}
@property (nonatomic,retain,readonly) id object;
@property (nonatomic,retain,readonly) NSString* keyPath;
@property (nonatomic,assign) id value;
@property (nonatomic,readonly) NSString* name;
@property (nonatomic,retain,readonly) CKClassPropertyDescriptor* descriptor;

+ (CKObjectProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath;
+ (CKObjectProperty*)propertyWithObject:(id)object;
- (id)initWithObject:(id)object keyPath:(NSString*)keyPath;
- (id)initWithObject:(id)object;

- (CKObjectPropertyMetaData*)metaData;
- (id)value;
- (void)setValue:(id)value;
- (id)convertToClass:(Class)type;
- (Class)type;

- (BOOL)isReadOnly;

- (void)insertObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)removeAllObjects;
- (NSInteger)count;

//FIXME : for property grids. think to a good way to setup configuration for properties in generic controllers (see metaData)
//Here we should not have dependencies other than Foundation !
- (CKDocumentCollection*)editorCollectionWithFilter:(NSString*)filter;
- (CKDocumentCollection*)editorCollectionForNewlyCreated;
- (CKDocumentCollection*)editorCollectionAtLocation:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius;
- (Class)tableViewCellControllerType DEPRECATED_ATTRIBUTE;

@end
