//
//  CKNSDictionary+Mappings.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNSObject+Introspection.h"

typedef id(^CKCustomMappingBlock)(id sourceObject, NSError** error);
typedef void(^CKMappingBlock)(id sourceObject,id object,NSString* destination,NSError** error);

//

/** TODO
 */
@interface NSObject (CKMapping_DEPRECATED_IN_CLOUDKIT_VERSION_1_7_AND_LATER) 

- (id)initWithDictionary:(NSDictionary*)sourceDictionary withMappings:(NSMutableDictionary*)mappings error:(NSError**)error  DEPRECATED_ATTRIBUTE;
- (void)mapWithDictionary:(NSDictionary*)sourceDictionary withMappings:(NSMutableDictionary*)mappings error:(NSError**)error  DEPRECATED_ATTRIBUTE;

@end

//

/** TODO
 */
@interface NSMutableArray (CKMapping_DEPRECATED_IN_CLOUDKIT_VERSION_1_7_AND_LATER) 
//keyPath is the keyPath in the sourceDictionary
- (void)mapWithDictionary:(NSDictionary*)sourceDictionary keyPath:(NSString*)keyPath objectClass:(Class)objectClass withMappings:(NSMutableDictionary*)mappings error:(NSError**)error  DEPRECATED_ATTRIBUTE;
@end

//


/** TODO
 */
@interface NSMutableDictionary (CKMapping_DEPRECATED_IN_CLOUDKIT_VERSION_1_7_AND_LATER) 
// Provide a block for a custom mappings
- (void)mapKeyPath:(NSString *)keyPath withValueFromBlock:(CKCustomMappingBlock)block DEPRECATED_ATTRIBUTE;

// FIXME: keyPath and destination should be inverted
// Standard mapping with block for os4 and later
- (void)mapKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo withBlock:(CKMappingBlock)block DEPRECATED_ATTRIBUTE;
// Standard mapping with block for os3
- (void)mapKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo withValueTransformerClass:(Class)valueTransformerClass DEPRECATED_ATTRIBUTE;

- (void)mapURLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapHttpURLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapStringForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapStringWithoutHTMLForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapTrimmedStringForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapIntForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapFloatForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapDateForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination required:(BOOL)bo DEPRECATED_ATTRIBUTE;

- (void)mapCollectionForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination objectClass:(Class)objectClass withMappings:(NSMutableDictionary*)mappings required:(BOOL)bo DEPRECATED_ATTRIBUTE;
- (void)mapObjectForKeyPath:(NSString*)keyPath toKeyPath:(NSString*)destination objectClass:(Class)objectClass withMappings:(NSMutableDictionary*)mappings required:(BOOL)bo DEPRECATED_ATTRIBUTE;

// --
@end
