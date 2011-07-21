//
//  CKMapping2.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-21.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

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

- (id)initWithObject:(id)sourceObject withMappings:(NSDictionary*)mappings;
- (void)setupWithObject:(id)sourceObject withMappings:(NSDictionary*)mappings;

- (id)initWithObject:(id)sourceObject withMappingsInFileNamed:(NSString*)fileName;
- (void)setupWithObject:(id)sourceObject withMappingsInFileNamed:(NSString*)fileName;


@end