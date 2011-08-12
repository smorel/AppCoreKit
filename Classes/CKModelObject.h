//
//  CKModelObject.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CKModelObjectPropertyMetaData.h"



/** TODO
 */
@protocol CKMigrating
- (void)propertyChanged:(CKClassPropertyDescriptor*)property serializedObject:(id)object;
- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object;
- (void)propertyAdded:(CKClassPropertyDescriptor*)property;
@end



typedef void(^CKModelObjectBlock)(CKClassPropertyDescriptor*,id);


/** TODO
 */
@interface CKModelObject : NSObject<NSCoding,NSCopying,CKMigrating> {
	BOOL _saving;
	BOOL _loading;
}

//This property is automatically set when serializing an object in core data
@property (nonatomic,copy) NSString* uniqueId;

//This property will get used to order items from core data
@property (nonatomic,copy) NSString* modelName;
@property (nonatomic,readonly) BOOL isSaving;
@property (nonatomic,readonly) BOOL isLoading;

+ (id)model;

//private
- (void)postInit;

@end



/** TODO
 */
@interface NSObject (CKModelObject)

- (void)copy : (id)other;
- (BOOL)isEqualToObject:(id)other;


@end



/** TODO
 */
@interface CKObjectValidationResults : NSObject{
}
@property(nonatomic,copy)NSString* modifiedKeyPath;
@property(nonatomic,retain)NSMutableArray* invalidProperties;
- (BOOL)isValid;

@end

/** TODO
 */
@interface NSObject (CKValidation)

- (CKObjectValidationResults*)validate;
- (void)bindValidationWithBlock:(void(^)(CKObjectValidationResults* validationResults))validationBlock;

@end

