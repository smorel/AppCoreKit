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
}

@property (nonatomic, assign) BOOL comparable;
@property (nonatomic, assign) BOOL serializable;
@property (nonatomic, assign) BOOL copiable;
@property (nonatomic, assign) BOOL deepCopy;
@property (nonatomic, assign) BOOL hashable;
@property (nonatomic, assign) BOOL creatable;

- (void)reset;
- (void)copy : (id)other;
+ (CKModelObjectPropertyMetaData*)propertyMetaDataForObject:(id)object property:(CKClassPropertyDescriptor*)property;

@end


typedef void(^CKModelObjectBlock)(CKClassPropertyDescriptor*,id);
@interface CKModelObject : NSObject<NSCoding,NSCopying,CKMigrating> {
}

@end
