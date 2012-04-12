//
//  CKClassPropertyDescriptor.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKPropertyExtendedAttributes;

/** TODO
 */
typedef enum{
	CKClassPropertyDescriptorTypeChar,
	CKClassPropertyDescriptorTypeInt,
	CKClassPropertyDescriptorTypeShort,
	CKClassPropertyDescriptorTypeLong,
	CKClassPropertyDescriptorTypeLongLong,
	CKClassPropertyDescriptorTypeUnsignedChar,
	CKClassPropertyDescriptorTypeUnsignedInt,
	CKClassPropertyDescriptorTypeUnsignedShort,
	CKClassPropertyDescriptorTypeUnsignedLong,
	CKClassPropertyDescriptorTypeUnsignedLongLong,
	CKClassPropertyDescriptorTypeFloat,
	CKClassPropertyDescriptorTypeDouble,
	CKClassPropertyDescriptorTypeCppBool,
	CKClassPropertyDescriptorTypeVoid,
	CKClassPropertyDescriptorTypeCharString,
	CKClassPropertyDescriptorTypeObject,
	CKClassPropertyDescriptorTypeClass,
	CKClassPropertyDescriptorTypeSelector,
	CKClassPropertyDescriptorTypeStruct,
	CKClassPropertyDescriptorTypeStructPointer,
	CKClassPropertyDescriptorTypeUnknown
}CKClassPropertyDescriptorType;


/** TODO
 */
typedef enum{
	CKClassPropertyDescriptorAssignementTypeCopy,
	CKClassPropertyDescriptorAssignementTypeRetain,
	CKClassPropertyDescriptorAssignementTypeWeak,
	CKClassPropertyDescriptorAssignementTypeAssign
}CKClassPropertyDescriptorAssignementType;


/** TODO
 */
@interface CKClassPropertyDescriptor : NSObject{
	NSString* name;
	NSString* className;
	NSString* encoding;
	NSInteger typeSize;
	Class type;
	NSString* attributes;
	CKClassPropertyDescriptorType propertyType;
	CKClassPropertyDescriptorAssignementType assignementType;
	BOOL isReadOnly;
	
	SEL extendedAttributesSelector;
	SEL insertSelector;
	SEL removeSelector;
	SEL removeAllSelector;
}

@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) Class type;
@property (nonatomic, assign, readwrite) NSInteger typeSize;
@property (nonatomic, retain, readwrite) NSString *className;
@property (nonatomic, retain, readwrite) NSString *encoding;
@property (nonatomic, retain, readwrite) NSString *attributes;
@property (nonatomic, assign, readwrite) CKClassPropertyDescriptorType propertyType;
@property (nonatomic, assign, readwrite) CKClassPropertyDescriptorAssignementType assignementType;
@property (nonatomic, assign, readwrite) BOOL isReadOnly;
@property (nonatomic, assign, readwrite) SEL extendedAttributesSelector;
@property (nonatomic, assign, readwrite) SEL insertSelector;
@property (nonatomic, assign, readwrite) SEL removeSelector;
@property (nonatomic, assign, readwrite) SEL removeAllSelector;

- (CKPropertyExtendedAttributes*)extendedAttributesForInstance:(id)instance;

+ (CKClassPropertyDescriptor*) classDescriptorForPropertyNamed:(NSString*)name withClass:(Class)c assignment:(CKClassPropertyDescriptorAssignementType)assignment readOnly:(BOOL)readOnly;
+ (CKClassPropertyDescriptor*) structDescriptorForPropertyNamed:(NSString*)name structName:(NSString*)structName structEncoding:(NSString*)encoding structSize:(NSInteger)size readOnly:(BOOL)readOnly;
+ (CKClassPropertyDescriptor*) boolDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly;
+ (CKClassPropertyDescriptor*) floatDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly;
+ (CKClassPropertyDescriptor*) intDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly;
+ (CKClassPropertyDescriptor*) classDescriptorForNativePropertyNamed:(NSString*)name nativeType:(CKClassPropertyDescriptorType)type readOnly:(BOOL)readOnly;

-(NSString*)getTypeDescriptor;

@end


/** TODO
 */
@interface CKClassPropertyDescriptorManager : NSObject{
	NSMutableDictionary* _propertiesByClassName;
	NSMutableDictionary* propertiesByClassNameByName;
	NSMutableDictionary* _viewPropertiesByClassName;
	NSMutableDictionary* _propertyNamesByClassName;
}

+ (CKClassPropertyDescriptorManager*)defaultManager;

- (NSArray*)allPropertiesForClass:(Class)type;
- (NSArray*)allViewsPropertyForClass:(Class)type;
- (NSArray*)allPropertieNamesForClass:(Class)type;
- (CKClassPropertyDescriptor*)property:(NSString*)name forClass:(Class)type;
- (void)addPropertyDescriptor:(CKClassPropertyDescriptor*)descriptor forClass:(Class)c;

@end

