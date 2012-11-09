//
//  UIFont+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 */
@interface UIFont (CKValueTransformer)

/**
 */
+ (UIFont*)convertFromNSString:(NSString*)str;

/**
 */
+ (UIFont*)convertFromNSArray:(NSArray*)ar;

/**
 */
+ (NSString*)convertToNSString:(UIFont*)font;


@end