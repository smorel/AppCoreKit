//
//  NSDate+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 */
@interface NSDate (CKValueTransformer)

/**
 */
+ (NSDate*)convertFromNSString:(NSString*)str withFormat:(NSString*)format;

/**
 */
+ (NSString*)convertToNSString:(NSDate*)n withFormat:(NSString*)format;

@end
