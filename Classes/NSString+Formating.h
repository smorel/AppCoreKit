//
//  NSString+Formating.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 */
@interface NSString (Formating)

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
