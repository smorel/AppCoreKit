//
//  ObjectIntrospection.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


/*
 The property is read-only (readonly).
 C
 The property is a copy of the value last assigned (copy).
 &
 The property is a reference to the value last assigned (retain).
 N
 The property is non-atomic (nonatomic).
 G<name>
 The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
 S<name>
 The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
 D
 The property is dynamic (@dynamic).
 W
 The property is a weak reference (__weak).
 P
 The property is eligible for garbage collection.
 */

typedef BOOL(^CKObjectPredicate)(id);

typedef enum{
	CKObjectPropertyTypeChar,
	CKObjectPropertyTypeInt,
	CKObjectPropertyTypeShort,
	CKObjectPropertyTypeLong,
	CKObjectPropertyTypeLongLong,
	CKObjectPropertyTypeUnsignedChar,
	CKObjectPropertyTypeUnsignedInt,
	CKObjectPropertyTypeUnsignedShort,
	CKObjectPropertyTypeUnsignedLong,
	CKObjectPropertyTypeUnsignedLongLong,
	CKObjectPropertyTypeFloat,
	CKObjectPropertyTypeDouble,
	CKObjectPropertyTypeCppBool,
	CKObjectPropertyTypeVoid,
	CKObjectPropertyTypeCharString,
	CKObjectPropertyTypeObject,
	CKObjectPropertyTypeClass,
	CKObjectPropertyTypeSelector,
	CKObjectPropertyTypeUnknown
}CKObjectPropertyType;

typedef enum{
	CKObjectPropertyAssignementTypeCopy,
	CKObjectPropertyAssignementTypeRetain,
	CKObjectPropertyAssignementTypeWeak,
	CKObjectPropertyAssignementTypeAssign
}CKObjectPropertyAssignementType;

@interface CKObjectProperty : NSObject{
	NSString* name;
	Class type;
	NSString* attributes;
	SEL metaDataSelector;
	CKObjectPropertyType propertyType;
	CKObjectPropertyAssignementType assignementType;
}

@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) Class type;
@property (nonatomic, retain, readwrite) NSString *attributes;
@property (nonatomic, assign, readwrite) SEL metaDataSelector;
@property (nonatomic, assign, readwrite) CKObjectPropertyType propertyType;
@property (nonatomic, assign, readwrite) CKObjectPropertyAssignementType assignementType;

-(NSString*)getTypeDescriptor;
- (NSString*)className;

@end


@interface CKObjectPropertyManager : NSObject{
	NSMutableDictionary* _propertiesByClassName;
	NSMutableDictionary* _propertyNamesByClassName;
}

+ (CKObjectPropertyManager*)defaultManager;
- (NSArray*)allPropertiesForClass:(Class)class;
- (NSArray*)allPropertieNamesForClass:(Class)class;

@property (nonatomic, retain, readonly) NSDictionary *propertiesByClassName;
@property (nonatomic, retain, readonly) NSDictionary *propertyNamesByClassName;

@end


@interface NSObject (CKNSObjectIntrospection)

- (NSString*)className;
+ (BOOL)isKindOf:(Class)type parentType:(Class)parentType;
+ (BOOL)isExactKindOf:(Class)type parentType:(Class)parentType;

- (NSArray*)allProperties;
- (NSArray*)allPropertyNames;

- (NSMutableArray*)subObjects :(CKObjectPredicate)expandWith insertWith:(CKObjectPredicate)insertWith includeSelf:(BOOL)includeSelf;

+ (SEL)insertorForProperty : (NSString*)propertyName;
+ (SEL)keyValueInsertorForProperty : (NSString*)propertyName;
+ (SEL)typeCheckSelectorForProperty : (NSString*)propertyName;
+ (SEL)setSelectorForProperty : (NSString*)propertyName;
+ (SEL)propertyMetaDataSelectorForProperty : (NSString*)propertyName;

+(CKObjectProperty*) property:(Class)c forKey:(NSString*)name;
+(CKObjectProperty*) property:(id)object forKeyPath:(NSString*)keyPath;

- (int)memorySizeIncludingSubObjects : (BOOL)includeSubObjects;

@end
