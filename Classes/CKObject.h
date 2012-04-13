//
//  CKObject.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKClassPropertyDescriptor.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKNSObject+CKRuntime.h"

/** TODO
 */
@protocol CKMigrating
- (void)propertyChanged:(CKClassPropertyDescriptor*)property serializedObject:(id)object;
- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object;
- (void)propertyAdded:(CKClassPropertyDescriptor*)property;
@end


/** TODO
 */
@interface CKObject : NSObject<NSCoding,NSCopying,CKMigrating> {
	BOOL _saving;
	BOOL _loading;
}

//This property is automatically set when serializing an object in core data
@property (nonatomic,copy) NSString* uniqueId;
@property (nonatomic,copy) NSString* objectName;

//This property will get used to order items from core data
@property (nonatomic,readonly) BOOL isSaving;
@property (nonatomic,readonly) BOOL isLoading;

+ (id)object;

//private
- (void)postInit;

@end


/** TODO
 */
@interface NSObject (CKObject)

- (void)copyPropertiesFromObject : (id)other;
- (BOOL)isEqualToObject:(id)other;

@end


/********************************* DEPRECATED *********************************
 */


//DEPRECATED_IN_CLOUDKIT_1_7_15_AND_LATER
@interface CKModelObject : CKObject
@property (nonatomic,assign,readwrite) NSString* modelName DEPRECATED_ATTRIBUTE;
+ (id)model DEPRECATED_ATTRIBUTE;
@end


#import "CKNSObject+Validation.h"
#import "CKObject+CKSingleton.h"
