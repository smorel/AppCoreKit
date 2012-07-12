//
//  NSData+SHA1.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// FIXME: This interface is misleading, these encoding
// should be on NSString instead.
// Another interface should provide a way to do string -> string.

/**
 */
@interface NSData (CKNSDataSHA1Additions)

///-----------------------------------
/// @name Creating and Initializing Encoded Data Objects
///-----------------------------------

/** 
 */
+ (NSData *)dataWithSHA1EncodedString:(NSString *)string;

/** 
 */
+ (NSData *)dataWithMD5EncodedString:(NSString *)string;

///-----------------------------------
/// @name Representing Data as Strings
///-----------------------------------

/** 
 */
- (NSString *)hexadecimalRepresentation;

@end
