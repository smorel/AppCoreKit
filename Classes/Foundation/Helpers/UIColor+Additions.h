//
//  UIColor+Additions.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 */
@interface UIColor (CKUIColorAdditions)

///-----------------------------------
/// @name Creating a UIColor Object from Component Values
///-----------------------------------

/** 
 */
+ (UIColor *)colorWithRGBValue:(NSUInteger)value;

/** 
 */
+ (UIColor *)colorWithRedInt:(NSUInteger)red greenInt:(NSUInteger)green blueInt:(NSUInteger)blue alphaInt:(NSUInteger)alpha;


///-----------------------------------
/// @name Retrieving Color Information
///-----------------------------------

/** 
 */
- (UIColor *)RGBColor;

@end
