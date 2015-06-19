//
//  CKMappingContext.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCascadingTree.h"

/* Errors
 */
extern NSString* const CKMappingErrorDomain;
extern NSString* const CKMappingErrorDetailsKey;
extern NSString* const CKMappingErrorCodeKey;

#define CKMappingErrorCodeInvalidSourceData     1
#define CKMappingErrorCodeInvalidObjectClass    2
#define CKMappingErrorCodeMissingRequieredValue 3
#define CKMappingErrorCodeInvalidProperty       4
#define CKMappingErrorCodeTransformNotSupported 5


/**
 */
@interface CKMappingContext : NSObject

///-----------------------------------
/// @name Identifying the mapping context at runtime
///-----------------------------------

/**
 */
@property(nonatomic,retain)id identifier;

///-----------------------------------
/// @name Accessing instance of CKMappingContext
///-----------------------------------

/**
 */
+ (CKMappingContext*)contextWithIdentifier:(id)identifier;

///-----------------------------------
/// @name Importing .mappings files content
///-----------------------------------

/**
 */
+ (void)loadContentOfFileNamed:(NSString*)name;

///-----------------------------------
/// @name Applying Mapping from value
///-----------------------------------

/** value should be a collection (NSArray, CKCollection)
 */
- (NSArray*)objectsFromValue:(id)value ofClass:(Class)type error:(NSError**)error;

/** value should be a collection (NSArray, CKCollection)
 */
- (NSArray*)objectsFromValue:(id)value ofClass:(Class)type reversed:(BOOL)reversed error:(NSError**)error;

/**
 */
- (id)objectFromValue:(id)value ofClass:(Class)type error:(NSError**)error;

/**
 */
- (id)objectFromValue:(id)value ofClass:(Class)type reversed:(BOOL)reversed error:(NSError**)error;

//apply the context mappings to the object

/**
 */
- (id)mapValue:(id)value toObject:(id)object error:(NSError**)error;

/**
 */
- (id)mapValue:(id)value toObject:(id)object reversed:(BOOL)reversed error:(NSError**)error;

/** Reserved for mappings definitions containing the object definition for the return object
 //if source is collection return a NSArray else return an instance defined by the objectClass of the mapping definition
 */
- (id)objectFromValue:(id)value error:(NSError**)error;

/** Reserved for mappings definitions containing the object definition for the return object
 //if source is collection return a NSArray else return an instance defined by the objectClass of the mapping definition
 */
- (id)objectFromValue:(id)value reversed:(BOOL)reversed error:(NSError**)error;

/** Reserved for mappings definitions containing the object definition for the return object
 //if source is collection return a NSArray else return an instance defined by the objectClass of the mapping definition
 */
- (NSArray*)objectsFromValue:(id)value error:(NSError**)error;

/** Reserved for mappings definitions containing the object definition for the return object
 //if source is collection return a NSArray else return an instance defined by the objectClass of the mapping definition
 */
- (NSArray*)objectsFromValue:(id)value reversed:(BOOL)reversed error:(NSError**)error;

///-----------------------------------
/// @name Defining mapping context programmatically
///-----------------------------------

/**
 */
- (void)setObjectClass:(Class)type;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath transformBlock:(id(^)(id source))transformBlock;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath transformTarget:(id)target action:(SEL)action;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value transformBlock:(id(^)(id source))transformBlock;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value transformTarget:(id)target action:(SEL)action;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional transformBlock:(id(^)(id source))transformBlock;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional transformTarget:(id)target action:(SEL)action;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath objectClass:(Class)objectClass withMappingsContextIdentifier:(id)contextIdentifier;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional objectClass:(Class)objectClass withMappingsContextIdentifier:(id)contextIdentifier;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath withMappingsContextIdentifier:(id)contextIdentifier;

/**
 */
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath optional:(BOOL)optional withMappingsContextIdentifier:(id)contextIdentifier;

- (BOOL)isEmpty;

@end



@interface NSObject(CKMappings)

+ (id)objectFromJsonFileNamed:(NSString*)filename extension:(NSString*)extension keyPathToJsonDictionary:(NSString*)keyPathToJsonDictionary mappings:(NSString*)mappings error:(NSError**)error;

+ (NSArray*)objectsFromJsonFileNamed:(NSString*)filename extension:(NSString*)extension keyPathToJsonArray:(NSString*)keyPathToJsonArray mappings:(NSString*)mappings range:(NSRange)range error:(NSError**)error;

+ (id)objectFromJsonFileAtPath:(NSString*)filePath keyPathToJsonDictionary:(NSString*)keyPathToJsonDictionary mappings:(NSString*)mappings error:(NSError**)error;

+ (NSArray*)objectsFromJsonFileAtPath:(NSString*)filePath keyPathToJsonArray:(NSString*)keyPathToJsonArray mappings:(NSString*)mappings range:(NSRange)range error:(NSError**)error;

@end

