//
//  NSString+Parsing.h
//  AppCoreKit
//
//  Created by Jean-Philippe Martin.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 */
@interface NSString (Parsing) 

///-----------------------------------
/// @name Parsing String Content
///-----------------------------------

/** 
 */
- (NSString *)stringByDeletingHTMLTags;

/** This works only for US phone numbers
 */
+ (BOOL)formatAsPhoneNumberUsingTextField:(UITextField*)textfield range:(NSRange)range replacementString:(NSString*)string;

/**
 */
+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string allowingFloatingSeparators:(BOOL)allowingFloatingSeparators;

/**
 */
+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string minimumLength:(NSInteger)min allowingFloatingSeparators:(BOOL)allowingFloatingSeparators;

/**
 */
+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string maximumLength:(NSInteger)max allowingFloatingSeparators:(BOOL)allowingFloatingSeparators;

/**
 */
+ (BOOL)formatAsAlphanumericUsingTextField:(UITextField*)textField range:(NSRange)range replacementString:(NSString*)string minimumLength:(NSInteger)min maximumLength:(NSInteger)max allowingFloatingSeparators:(BOOL)allowingFloatingSeparators;

@end
