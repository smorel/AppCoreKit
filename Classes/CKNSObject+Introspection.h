//
//  ObjectIntrospection.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


typedef BOOL(^CKObjectPredicate)(id);
CKObjectPredicate CKObjectPredicateMakeIsOfType(Class type1,...);
CKObjectPredicate CKObjectPredicateMakeIsNotOfType(Class type1,...);
CKObjectPredicate CKObjectPredicateMakeExpandAll();


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

@interface CKObjectProperty : NSObject{
	NSString* name;
	Class type;
	NSString* attributes;
	SEL metaDataSelector;
	CKObjectPropertyType propertyType;
}

@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) Class type;
@property (nonatomic, retain, readwrite) NSString *attributes;
@property (nonatomic, assign, readwrite) SEL metaDataSelector;
@property (nonatomic, assign, readwrite) CKObjectPropertyType propertyType;

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
