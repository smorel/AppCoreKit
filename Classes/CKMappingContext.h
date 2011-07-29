//
//  CKMapping2.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-21.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCascadingTree.h"
 
/** TODO
 */
@interface CKMappingContext : NSObject{
    NSMutableDictionary* _dictionary;
    id _identifier;
}

@property(nonatomic,retain)id identifier;

///-----------------------------------
/// @name Accessing instance of CKMappingContext
///-----------------------------------

+ (CKMappingContext*)contextWithIdentifier:(id)identifier;
+ (void)loadContentOfFileNamed:(NSString*)name;

///-----------------------------------
/// @name Applying Mapping from value
///-----------------------------------

//value should be a collection (NSArray, CKDocumentCollection)
- (NSArray*)objectsFromValue:(id)value ofClass:(Class)type;
- (NSArray*)objectsFromValue:(id)value ofClass:(Class)type reversed:(BOOL)reversed;
- (id)objectFromValue:(id)value ofClass:(Class)type;
- (id)objectFromValue:(id)value ofClass:(Class)type reversed:(BOOL)reversed;

//apply the context mappings to the object
- (id)mapValue:(id)value toObject:(id)object;
- (id)mapValue:(id)value toObject:(id)object reversed:(BOOL)reversed;

//Reserved for mappings definitions containing the object definition for the return object
//if source is collection return a NSArray else return an instance defined by the objectClass of the mapping definition
- (id)objectFromValue:(id)value;
- (id)objectFromValue:(id)value reversed:(BOOL)reversed;
- (NSArray*)objectsFromValue:(id)value;
- (NSArray*)objectsFromValue:(id)value reversed:(BOOL)reversed;

///-----------------------------------
/// @name Mappings Definition Methods
///-----------------------------------

- (void)setObjectClass:(Class)type;

- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath transformBlock:(id(^)(id source))transformBlock;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath transformTarget:(id)target action:(SEL)action;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value transformBlock:(id(^)(id source))transformBlock;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath defaultValue:(id)value transformTarget:(id)target action:(SEL)action;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath requiered:(BOOL)requiered;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath requiered:(BOOL)requiered transformBlock:(id(^)(id source))transformBlock;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath requiered:(BOOL)requiered transformTarget:(id)target action:(SEL)action;

//valid for object property or array, collection sub objects
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath objectClass:(Class)objectClass withMappingsContextIdentifier:(id)contextIdentifier;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath requiered:(BOOL)requiered objectClass:(Class)objectClass withMappingsContextIdentifier:(id)contextIdentifier;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath withMappingsContextIdentifier:(id)contextIdentifier;
- (void)setKeyPath:(NSString*)keyPath fromKeyPath:(NSString*)sourceKeyPath requiered:(BOOL)requiered withMappingsContextIdentifier:(id)contextIdentifier;

- (BOOL)isEmpty;

@end


