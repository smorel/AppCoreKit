//
//  NSPredicate+Addition.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSPredicate (CKNSPredicateAdditions)

///-----------------------------------
/// @name Number predicates
///-----------------------------------

/** 
 This creates a predicate that will check if the evaluatedObject is a NSNumber and the value is containes within the specified range
 @param NSRange range : The valid range.
 @return A configured predicate.
 */
+ (NSPredicate*)predicateForFloatInRange:(NSRange)range;

///-----------------------------------
/// @name String predicates
///-----------------------------------

/** 
 This creates a predicate that will check if the evaluatedObject is a NSString not nil, not NSNull with a length > 0.
 @return A configured predicate.
 */
+ (NSPredicate*)predicateForValidString;

/** 
 This creates a predicate that will check if the evaluatedObject is a NSString not nil, not NSNull with a length > 0 and < to the specified length.
 @param NSUInteger length : The maximum length for string.
 @return A configured predicate.
 */
+ (NSPredicate*)predicateForValidStringWithMaximumLength:(NSUInteger)length;

@end
