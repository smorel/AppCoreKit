//
//  NSString+Validations.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "NSString+Validations.h"

@implementation NSString (CKNSStringValidationsAdditions)

- (BOOL)isValidFormat:(NSString *)format {
	return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", format] evaluateWithObject:self];
}

- (BOOL)isValidEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	return [[self lowercaseString] isValidFormat:emailRegex];
}


@end
