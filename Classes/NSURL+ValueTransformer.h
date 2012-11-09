//
//  NSURL+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 */
@interface NSURL (CKValueTransformer)

/**
 */
+ (NSURL*)convertFromNSString:(NSString*)str;

/**
 */
+ (NSString*)convertToNSString:(NSURL*)n;

@end