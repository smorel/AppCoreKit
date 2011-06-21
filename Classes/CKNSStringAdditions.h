//
//  CKNSStringAdditions.h
//
//  Created by Fred Brunel on 04/08/2007.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CKNSString+URIQuery.h"
#import "CKNSString+Validations.h"
#import "CKNSString+Parsing.h"

@interface NSString (CKNSStringAdditions)

// Returns a new string containing an UUID
+ (NSString *)stringWithNewUUID;

// Returns a new string truncated to a specified length, adding an ellipsis at the end
- (NSString *)stringByTruncatingToLength:(NSUInteger)length withEllipsisString:(NSString *)ellipsis;

// Returns a new string using a lossy convertion of the receiver to ASCIIStringEncoding
- (NSString *)stringUsingASCIIEncoding;

@end
