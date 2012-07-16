//
//  CKObjectPropertyMetaData.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CKNSValueTransformer+NativeTypes.h"//for CKEnumDescriptor
#import "CKNSObject+Introspection.h"
#import "CKNSMutableDictionary+CKObjectPropertyMetaData.h"

/** Meta data is a way to extend how an object's property will react with several behaviours of the ClouKit like serialization, creation, data migration, property grid display, and conversions.
 
 by defining a selector - (void) yourPropertyNameMetaData:(CKObjectPropertyMetaData*)metaData in your classes, you will be able to customize how yourProperty will react in all the cases described previously.
 
 Concerning the property grid representation, there several ways to customize the representation of your property : enumDescriptor, valuesAndLabels,propertyCellControllerClass or nothing.
 
 propertyCellControllerClass will get used as the top priority. after, we'll use enumDescriptor or valuesAndLabels that should be used independently depending whether your represent an enum property or something else. and finally, property grids will automatically choose a controller class depending on the property type automatically.
 */
@interface CKObjectPropertyMetaData : NSObject{
	BOOL comparable;
	BOOL serializable;
	BOOL copiable;
	BOOL deepCopy;
	BOOL hashable;
	BOOL creatable;
	Class contentType;
	Protocol* contentProtocol;
    
    NSPredicate* validationPredicate;
    
	CKEnumDescriptor* enumDescriptor;
    BOOL multiselectionEnabled;
	NSString* dateFormat;
    
    //PropertyGrid Representation
	BOOL editable;
	NSDictionary* valuesAndLabels;
    Class propertyCellControllerClass;
    
    NSMutableDictionary* options;
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
@property (nonatomic, retain) CKEnumDescriptor* enumDescriptor;
/** 
 Working with enumDescriptor, this specify if the enum can have only one straigth value or is a combination of several values as flag.
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

/** 
 Specify options that could be used by various behaviours in app or in the cloudkit.
 */
@property (nonatomic, retain) NSMutableDictionary* options;

- (void)reset;
+ (CKObjectPropertyMetaData*)propertyMetaDataForObject:(id)object property:(CKClassPropertyDescriptor*)property;

@end

/** 
 DEPRECATED_IN_CLOUDKIT_1.7
 @see CKObjectPropertyMetaData
 */
@interface CKModelObjectPropertyMetaData : CKObjectPropertyMetaData{}
@end
