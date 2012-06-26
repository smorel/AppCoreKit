//
//  CKItem.h
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CKDomain;
@class CKAttribute;


/**
 */
@interface CKItem : NSManagedObject {
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) CKDomain *domain;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet* refAttributes;
@property (nonatomic, retain) NSSet* references;


@end



//

/**
 */
@interface CKItem (CKItemAccessors)

- (void)addAttributesObject:(CKAttribute *)value;
- (void)removeAttributesObject:(CKAttribute *)value;
- (void)addAttributes:(NSSet *)value;
- (void)removeAttributes:(NSSet *)value;
- (void)addRefAttributesObject:(CKAttribute *)value;
- (void)removeRefAttributesObject:(CKAttribute *)value;
- (void)addRefAttributes:(NSSet *)value;
- (void)removeRefAttributes:(NSSet *)value;

- (void)addReferencesObject:(NSManagedObject *)value;
- (void)removeReferencesObject:(NSManagedObject *)value;
- (void)addReferences:(NSSet *)value;
- (void)removeReferences:(NSSet *)value;

@end

//

/**
 */
@interface CKItem (CKItemRepresentations)

- (NSDictionary *)propertyListRepresentation;
- (NSDictionary *)attributesIndexedByName;

@end


/**
 */
@interface CKItem (CKItemModification)

- (void)updateAttributes:(NSDictionary*)attributes;
- (CKAttribute*)attributeNamed:(NSString*)attribute createIfNotFound:(BOOL)createIfNotFound;

@end


/**
 */
@interface CKItem (CKOptimizedItemModification)

- (void)updateAttribute:(CKAttribute*)attribute withValue:(NSString*)value;
- (void)updateAttribute:(CKAttribute*)attribute withItems:(NSArray*)items;
- (CKAttribute*)findOrCreateAttributeInDictionary:(NSDictionary*)indexedAttributes withName:(NSString*)name;

@end