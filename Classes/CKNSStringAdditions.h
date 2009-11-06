//
//  CKNSStringAdditions.h
//
//  Created by Fred Brunel on 04/08/2007.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CKNSStringAdditions)

// Returns a new string containing an UUID
+ (NSString *)stringWithNewUUID;

// Returns a new string truncated to a specified length, adding an ellipsis at the end
- (NSString *)stringTruncatedToLength:(NSUInteger)length withEllipsisString:(NSString *)ellipsis;

// Returns TRUE if this string is compliant with an Email format specification
- (BOOL)stringIsValidAsEmail:(BOOL)allowEmptyString;

@end
