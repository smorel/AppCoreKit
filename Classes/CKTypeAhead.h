//
//  CKTypeAhead.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//



#import <Foundation/Foundation.h>

/**
 */
@interface CKTypeAhead : NSObject

///-----------------------------------
/// @name Initializing Type Ahead objects
///-----------------------------------

/**
 */
- (id)initWithName:(NSString*)fileName;

///-----------------------------------
/// @name Identifying Type Ahead at runtime
///-----------------------------------

/**
 */
@property (nonatomic, retain) NSString *name;

///-----------------------------------
/// @name Querying Type Ahead
///-----------------------------------

/**
 */
- (NSArray*)stringsWithPrefix:(NSString*)prefix range:(NSRange)range;

/**
 */
- (NSArray*)stringsWithPrefix:(NSString*)prefix;

/**
 */
- (NSUInteger)numberOfStringsWithPrefix:(NSString*)prefix;

@end
