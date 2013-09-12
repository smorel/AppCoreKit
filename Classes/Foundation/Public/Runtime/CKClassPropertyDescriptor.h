//
//  CKClassPropertyDescriptor.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKPropertyExtendedAttributes;

/**
 */
typedef NS_ENUM(NSInteger, CKClassPropertyDescriptorType){
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
};


/**
 */
typedef NS_ENUM(NSInteger, CKClassPropertyDescriptorAssignementType){
	CKClassPropertyDescriptorAssignementTypeCopy,
	CKClassPropertyDescriptorAssignementTypeRetain,
	CKClassPropertyDescriptorAssignementTypeWeak,
	CKClassPropertyDescriptorAssignementTypeAssign
};


/**
 */
@interface CKClassPropertyDescriptor : NSObject

///-----------------------------------
/// @name Accessing property descriptor attributes 
///-----------------------------------

/**
 */
@property (nonatomic, retain, readwrite) NSString *name;

/**
 */
@property (nonatomic, assign, readwrite) Class type;

/**
 */
@property (nonatomic, assign, readwrite) NSInteger typeSize;

/**
 */
@property (nonatomic, retain, readwrite) NSString *className;

/**
 */
@property (nonatomic, retain, readwrite) NSString *encoding;

/**
 */
@property (nonatomic, retain, readwrite) NSString *attributes;

/**
 */
@property (nonatomic, assign, readwrite) CKClassPropertyDescriptorType propertyType;

/**
 */
@property (nonatomic, assign, readwrite) CKClassPropertyDescriptorAssignementType assignementType;

/**
 */
@property (nonatomic, assign, readwrite) BOOL isReadOnly;

/**
 */
@property (nonatomic, assign, readwrite) SEL extendedAttributesSelector;

/**
 */
@property (nonatomic, assign, readwrite) SEL insertSelector;

/**
 */
@property (nonatomic, assign, readwrite) SEL removeSelector;

/**
 */
@property (nonatomic, assign, readwrite) SEL removeAllSelector;

///-----------------------------------
/// @name Accessing property extended attributes 
///-----------------------------------

/**
 */
- (CKPropertyExtendedAttributes*)extendedAttributesForInstance:(id)instance;


///-----------------------------------
/// @name Creating property descriptor objects
///-----------------------------------

/**
 */
+ (CKClassPropertyDescriptor*) classDescriptorForPropertyNamed:(NSString*)name withClass:(Class)c assignment:(CKClassPropertyDescriptorAssignementType)assignment readOnly:(BOOL)readOnly;

/**
 */
+ (CKClassPropertyDescriptor*) structDescriptorForPropertyNamed:(NSString*)name structName:(NSString*)structName structEncoding:(NSString*)encoding structSize:(NSInteger)size readOnly:(BOOL)readOnly;

/**
 */
+ (CKClassPropertyDescriptor*) boolDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly;

/**
 */
+ (CKClassPropertyDescriptor*) floatDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly;

/**
 */
+ (CKClassPropertyDescriptor*) intDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly;

/**
 */
+ (CKClassPropertyDescriptor*) classDescriptorForNativePropertyNamed:(NSString*)name nativeType:(CKClassPropertyDescriptorType)type readOnly:(BOOL)readOnly;


@end


@interface CKEnumDescriptor : NSObject{}
@property(nonatomic,assign)BOOL isBitMask;
@property(nonatomic,retain)NSString* name;
@property(nonatomic,retain)NSDictionary* valuesAndLabels;
@end

#ifdef __cplusplus
extern "C" {
#endif
    
/**
 */
CKEnumDescriptor* CKEnumDefinitionFunc(NSString* name,BOOL bitmask, NSString* strValues, ...);
    
#ifdef __cplusplus
}
#endif

/**
 */
#define CKEnumDefinition(name,...) CKEnumDefinitionFunc(name,NO,[NSString stringWithUTF8String:#__VA_ARGS__],__VA_ARGS__)
#define CKBitMaskDefinition(name,...) CKEnumDefinitionFunc(name,YES,[NSString stringWithUTF8String:#__VA_ARGS__],__VA_ARGS__)