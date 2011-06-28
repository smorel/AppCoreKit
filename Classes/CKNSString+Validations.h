//
//  CKNSString+Validations.h
//  CloudKit
//
//  Created by Fred Brunel on 09-12-17.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSString (CKNSStringValidationsAdditions)

// Returns TRUE if the string is compliant with a specified regex
- (BOOL)isValidFormat:(NSString *)format;

// Returns TRUE if the string is compliant with an email format
- (BOOL)isValidEmail;

@end
