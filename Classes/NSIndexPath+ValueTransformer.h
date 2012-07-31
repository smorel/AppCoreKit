//
//  NSIndexPath+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSIndexPath (CKValueTransformer)

/**
 */
+ (NSIndexPath*)convertFromNSString:(NSString*)str;

/**
 */
+ (NSString*)convertToNSString:(NSIndexPath*)indexPath;

@end