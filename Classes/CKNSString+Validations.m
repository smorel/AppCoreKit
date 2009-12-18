//
//  CKNSString+Validations.m
//  CloudKit
//
//  Created by Fred Brunel on 09-12-17.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSString+Validations.h"

@implementation NSString (CKNSStringValidationsAdditions)

- (BOOL)isValidFormat:(NSString *)format {
	return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", format] evaluateWithObject:self];
}

- (BOOL)isValidEmail {
	return [self isValidFormat:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"];
}


@end
