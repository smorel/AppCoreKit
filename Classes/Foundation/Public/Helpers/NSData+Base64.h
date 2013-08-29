//
//  NSData+Base64.h
//
//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSData (CKNSDataBase64Additions)

///-----------------------------------
/// @name Creating and Initializing Encoded Data Objects
///-----------------------------------

/** 
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)aString;

///-----------------------------------
/// @name Representing Data as Strings
///-----------------------------------

/** 
 */
- (NSString *)base64EncodedString;

@end
