//
//  NSString+Validations.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSString (CKNSStringValidationsAdditions)

///-----------------------------------
/// @name Validating String content
///-----------------------------------

/** Returns TRUE if the string is compliant with a specified regex
 */
- (BOOL)isValidFormat:(NSString *)format;

/** Returns TRUE if the string is compliant with an email format
 */
- (BOOL)isValidEmail;

@end
