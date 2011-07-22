//
//  CKMapping2.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-21.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCascadingTree.h"

/* Format for mappings : Can be defined in a JSON file
      { 
         ObjectClass1 : {
                           keyPath : propertyTarget1,
                           ...
                           Key1.Key2. ... :   {
                                             requiered : YES,
                                             keyPath : "Key1.Key2.Key3. ...",
                                             transformSelector : "NSDateFromStringCustom:" //if keyPath points to a NSDate property we will transform the source using [NSDate NSDateFromStringCustom:sourceValue]
                                             
                                             //for objects that will get created in array or document collection properties
                                             contentType : "CKYourType"
                                             clearContent : YES,
                                             insertContentAtBegin : YES
                                             },
                           ...
                        },
         ...
      }
 */
 

/** TODO
 */
@interface NSObject (CKMapping2) 

- (id)initWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings;
- (void)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings;
- (void)setupWithObject:(id)sourceObject withMappings:(NSMutableDictionary*)mappings reversed:(BOOL)reversed;

- (id)initWithObject:(id)sourceObject withMappingsIdentifier:(NSString*)identifier;
- (void)setupWithObject:(id)sourceObject withMappingsIdentifier:(NSString*)identifier;

+ (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings;
+ (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(NSString*)identifier;

@end


/*
@interface NSMutableDictionary (CKMapping2)
- (void)setKeyPath: ... FromKeyPath:...;
- (void)mapKeyPath: ... FromKeyPath:... requiered:...;
- (void)mapKeyPath: ... FromKeyPath:... requiered:... objectClass:...;
- (void)mapKeyPath: ... FromKeyPath:... requiered:... objectClass:... transformBlock:^(id)djhfbjfdsh;
@end
*/


@interface CKMappingManager : CKCascadingTree {
}

+ (CKMappingManager*)defaultManager;

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName;
- (NSMutableDictionary*)mappingsForIdentifier:(NSString*)identifier;

- (void)loadContentOfFileNamed:(NSString*)name;
- (BOOL)importContentOfFileNamed:(NSString*)name;

- (id)objectFromValue:(id)sourceObject withMappings:(NSMutableDictionary*)mappings;
- (id)objectFromValue:(id)sourceObject withMappingsIdentifier:(NSString*)identifier;

@end

@interface NSMutableDictionary (CKMappingManager)

- (NSMutableDictionary*)mappingsForObject:(id)object propertyName:(NSString*)propertyName;

@end