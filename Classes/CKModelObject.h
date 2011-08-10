//
//  CKModelObject.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CKNSObject+Introspection.h"


/** TODO
 */
@protocol CKMigrating
- (void)propertyChanged:(CKClassPropertyDescriptor*)property serializedObject:(id)object;
- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object;
- (void)propertyAdded:(CKClassPropertyDescriptor*)property;
@end


/** Meta data is a way to extend how an object's property will react with several behaviours of the ClouKit like serialization, creation, data migration, property grid display, and conversions.
 
    by defining a selector - (void) yourPropertyNameMetaData:(CKModelObjectPropertyMetaData*)metaData in your classes, you will be able to customize how yourProperty will react in all the cases described previously.
 
    Concerning the property grid representation, there several ways to customize the representation of your property : enumDefinition, valuesAndLabels,propertyCellControllerClass or nothing.
    
    propertyCellControllerClass will get used as the top priority. after, we'll use enumDefinition or valuesAndLabels that should be used independently depending whether your represent an enum property or something else. and finally, property grids will automatically choose a controller class depending on the property type automatically.
 */
@interface CKModelObjectPropertyMetaData : NSObject{
	BOOL comparable;
	BOOL serializable;
	BOOL copiable;
	BOOL deepCopy;
	BOOL hashable;
	BOOL creatable;
	Class contentType;
	Protocol* contentProtocol;
    
    NSPredicate* validationPredicate;
    
	NSDictionary* enumDefinition;
    BOOL multiselectionEnabled;
	NSString* dateFormat;
    
    //PropertyGrid Representation
	BOOL editable;
	NSDictionary* valuesAndLabels;
    Class propertyCellControllerClass;
}

@property (nonatomic, assign) BOOL comparable;
@property (nonatomic, assign) BOOL serializable;
@property (nonatomic, assign) BOOL copiable;
@property (nonatomic, assign) BOOL deepCopy;
@property (nonatomic, assign) BOOL hashable;
@property (nonatomic, assign) BOOL creatable;

@property (nonatomic, assign) Class contentType;
@property (nonatomic, assign) Protocol* contentProtocol;
@property (nonatomic, retain) NSString* dateFormat;
@property (nonatomic, retain) NSPredicate* validationPredicate;

///-----------------------------------
/// @name PropertyGrid Representation
///-----------------------------------
/** 
 Specify if the property should be displayed or not in the property grid.
 */
@property (nonatomic, assign) BOOL editable;
/** 
 Specify the values and labels for an enum property as objectiveC runtime cannot give us this definition.
 This will get represented as an option cell in a property grid.
 */
@property (nonatomic, retain) NSDictionary* enumDefinition;
/** 
 Working with enumDefinition, this specify if the enum can have only one straigth value or is a combination of several values as flag.
 */
@property (nonatomic, assign) BOOL multiselectionEnabled;
/** 
 Specify a dictionary of values that should be of the same type than the property and their textual representation.
 This will get represented as an option cell in a property grid.
 */
@property (nonatomic, retain) NSDictionary* valuesAndLabels;
/** 
 Specify wich table view cell controller class should be instanciated to represent the property in a property grid.
 This cell controller should accept CKObjectProperty as value.
 */
@property (nonatomic, assign) Class propertyCellControllerClass;

- (void)reset;
+ (CKModelObjectPropertyMetaData*)propertyMetaDataForObject:(id)object property:(CKClassPropertyDescriptor*)property;

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

