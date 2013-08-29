//
//  UIImage+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 */
@interface UIImage (CKValueTransformer)

/**
 */
+ (UIImage*)convertFromNSString:(NSString*)str;

/**
 */
+ (UIImage*)convertFromNSURL:(NSURL*)url;

/**
 */
+ (UIImage*)convertFromNSArray:(NSArray*)array;

/**
 */
+ (NSString*)convertToNSString:(UIImage*)image;

@end