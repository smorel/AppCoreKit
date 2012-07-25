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
+ (BOOL)formatAsPhoneNumberUsingTextFied:(UITextField*)textfield range:(NSRange)range replacementString:(NSString*)string;

@end
