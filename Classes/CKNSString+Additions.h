//
//  CKNSString+Additions.h
//
//  Created by Fred Brunel on 04/08/2007.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CKNSString+URIQuery.h"
#import "CKNSString+Validations.h"
#import "CKNSString+Parsing.h"

/**
 */
@interface NSString (CKNSStringAdditions)

///-----------------------------------
/// @name Creating and Initializing Strings
///-----------------------------------

/** Returns a new string containing an UUID
 */
+ (NSString *)stringWithNewUUID;

///-----------------------------------
/// @name Dividing Strings
///-----------------------------------

/** Returns a new string truncated to a specified length, adding an ellipsis at the end
 */
- (NSString *)stringByTruncatingToLength:(NSUInteger)length withEllipsisString:(NSString *)ellipsis;


///-----------------------------------
/// @name Converting Strings
///-----------------------------------
/** Returns a new string using a lossy convertion of the receiver to ASCIIStringEncoding
  */
- (NSString *)stringUsingASCIIEncoding;

@end
