//
//  UIColor+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 */
@interface UIColor (CKValueTransformer)

/**
 */
+ (UIColor*)convertFromNSString:(NSString*)str;

/**
 */
+ (UIColor*)convertFromNSNumber:(NSNumber*)n;

/**
 */
+ (NSString*)convertToNSString:(UIColor*)color;

@end