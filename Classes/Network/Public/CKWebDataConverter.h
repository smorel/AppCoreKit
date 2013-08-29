//
//  CKWebDataConverter.h
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface CKWebDataConverter : NSObject

///-----------------------------------
/// @name Registering Converter
///-----------------------------------

/**
 */
+ (void)addConverter:(id (^)(NSData *data, NSURLResponse *response, NSError** error))converter forMIMEPredicate:(NSPredicate*)predicate;

///-----------------------------------
/// @name Converting Data
///-----------------------------------

/**
 */
+(id)convertData:(NSData*)data fromResponse:(NSURLResponse*)response error:(NSError**)error;

@end
