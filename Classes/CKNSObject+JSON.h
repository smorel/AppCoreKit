//
//  CKNSObject+JSON.h
//  CloudKit
//
//  Created by Fred Brunel on 11-01-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSObject (CKNSObjectJSON) 

///-----------------------------------
/// @name Parsing JSON Data
///-----------------------------------

/** 
 */
+ (id)objectFromJSONData:(NSData *)data;

/** 
 */
+ (id)objectFromJSONData:(NSData *)data error:(NSError **)error;


///-----------------------------------
/// @name Generating JSON Representation
///-----------------------------------

/** 
 */
- (id)JSONRepresentation;


@end
