//
//  NSNumber+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSNumber (CKValueTransformer)

/**
 */
+ (NSNumber*)convertFromNSString:(NSString*)str;

/**
 */
+ (NSString*)convertToNSString:(NSNumber*)n;

@end