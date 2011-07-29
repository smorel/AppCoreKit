//
//  NFBDataSourceMapper.h
//  NFB
//
//  Created by Sebastien Morel on 11-02-24.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSObject+Introspection.h"

typedef id(^CKCustomMappingBlock)(id sourceObject, NSError** error);
typedef void(^CKMappingBlock)(id sourceObject,id object,NSString* destination,NSError** error);

//

/** TODO
 */
@interface NSObject (CKMapping) 

- (id)initWithDictionary:(NSDictionary*)sourceDictionary withMappings:(NSMutableDictionary*)mappings error:(NSError**)error;
- (void)mapWithDictionary:(NSDictionary*)sourceDictionary withMappings:(NSMutableDictionary*)mappings error:(NSError**)error;

@end

//

/** TODO
 */
@interface NSMutableArray (CKMapping)
//keyPath is the keyPath in the sourceDictionary
- (void)mapWithDictionary:(NSDictionary*)sourceDictionary keyPath:(NSString*)keyPath objectClass:(Class)objectClass withMappings:(NSMutableDictionary*)mappings error:(NSError**)error;
@end

//


/** TODO
 */
@interface NSMutableDictionary (CKMapping)
// Provide a block for a custom mappings
- (void)mapKeyPath:(NSString *)keyPath withValueFromBlock:(CKCustomMappingBlock)block;

// FIXME: keyPath and destination should be inverted
// Standard mapping with block for os4 and later
- (void)mapKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo withBlock:(CKMappingBlock)block;
// Standard mapping with block for os3
- (void)mapKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo withValueTransformerClass:(Class)valueTransformerClass;

- (void)mapURLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;
- (void)mapHttpURLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;
- (void)mapStringForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;
- (void)mapStringWithoutHTMLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;
- (void)mapTrimmedStringForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;
- (void)mapIntForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;
- (void)mapFloatForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;
- (void)mapDateForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo;

- (void)mapCollectionForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination objectClass:(Class)objectClass withMappings:(NSMutableDictionary*)mappings required:(BOOL)bo;
- (void)mapObjectForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination objectClass:(Class)objectClass withMappings:(NSMutableDictionary*)mappings required:(BOOL)bo;

// --
@end
