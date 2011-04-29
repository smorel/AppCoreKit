//
//  CKClassPropertyDescriptor.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


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
	CKClassPropertyDescriptorTypeUnknown
}CKClassPropertyDescriptorType;

typedef enum{
	CKClassPropertyDescriptorAssignementTypeCopy,
	CKClassPropertyDescriptorAssignementTypeRetain,
	CKClassPropertyDescriptorAssignementTypeWeak,
	CKClassPropertyDescriptorAssignementTypeAssign
}CKClassPropertyDescriptorAssignementType;

@interface CKClassPropertyDescriptor : NSObject{
	NSString* name;
	Class type;
	NSString* attributes;
	SEL metaDataSelector;
	CKClassPropertyDescriptorType propertyType;
	CKClassPropertyDescriptorAssignementType assignementType;
	BOOL isReadOnly;
}

@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) Class type;
@property (nonatomic, retain, readwrite) NSString *attributes;
@property (nonatomic, assign, readwrite) SEL metaDataSelector;
@property (nonatomic, assign, readwrite) CKClassPropertyDescriptorType propertyType;
@property (nonatomic, assign, readwrite) CKClassPropertyDescriptorAssignementType assignementType;
@property (nonatomic, assign, readwrite) BOOL isReadOnly;

-(NSString*)getTypeDescriptor;
- (NSString*)className;

@end


@interface CKClassPropertyDescriptorManager : NSObject{
	NSMutableDictionary* _propertiesByClassName;
	NSMutableDictionary* _viewPropertiesByClassName;
	NSMutableDictionary* _propertyNamesByClassName;
}

+ (CKClassPropertyDescriptorManager*)defaultManager;
- (NSArray*)allPropertiesForClass:(Class)class;
- (NSArray*)allViewsPropertyForClass:(Class)class;
- (NSArray*)allPropertieNamesForClass:(Class)class;
- (CKClassPropertyDescriptor*)property:(NSString*)name forClass:(Class)class;

@property (nonatomic, retain, readonly) NSDictionary *propertiesByClassName;
@property (nonatomic, retain, readonly) NSDictionary *propertyNamesByClassName;

@end

