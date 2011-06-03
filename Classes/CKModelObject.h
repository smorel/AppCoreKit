//
//  CKModelObject.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Introspection.h"


@protocol CKMigrating
- (void)propertyChanged:(CKClassPropertyDescriptor*)property serializedObject:(id)object;
- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object;
- (void)propertyAdded:(CKClassPropertyDescriptor*)property;
@end


@interface CKModelObjectPropertyMetaData : NSObject{
	BOOL comparable;
	BOOL serializable;
	BOOL copiable;
	BOOL deepCopy;
	BOOL hashable;
	BOOL creatable;
	BOOL editable;
	NSDictionary* enumDefinition;
	NSDictionary* valuesAndLabels;
	Class contentType;
	NSString* dateFormat;
}

@property (nonatomic, assign) BOOL comparable;
@property (nonatomic, assign) BOOL serializable;
@property (nonatomic, assign) BOOL copiable;
@property (nonatomic, assign) BOOL deepCopy;
@property (nonatomic, assign) BOOL hashable;
@property (nonatomic, assign) BOOL creatable;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, retain) NSDictionary* enumDefinition;
@property (nonatomic, retain) NSDictionary* valuesAndLabels;
@property (nonatomic, assign) Class contentType;
@property (nonatomic, retain) NSString* dateFormat;

- (void)reset;
+ (CKModelObjectPropertyMetaData*)propertyMetaDataForObject:(id)object property:(CKClassPropertyDescriptor*)property;

@end


typedef void(^CKModelObjectBlock)(CKClassPropertyDescriptor*,id);
@interface CKModelObject : NSObject<NSCoding,NSCopying,CKMigrating> {
	BOOL _saving;
}

//This property is automatically set when serializing an object in core data
@property (nonatomic,retain) NSString* uniqueId;

//This property will get used to order items from core data
@property (nonatomic,retain) NSString* modelName;

+ (id)model;

@end

@interface NSObject (CKModelObject)

- (void)copy : (id)other;
- (BOOL)isEqualToObject:(id)other;

+ (NSDictionary*)validationPredicates;
- (BOOL)isValid;

@end