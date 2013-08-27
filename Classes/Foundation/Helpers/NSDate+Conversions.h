//
//  NSDate+Conversions.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSDate (CKNSDateConversionsAdditions)

///-----------------------------------
/// @name Creating and Initializing Date Objects
///-----------------------------------

/** Returns a date from a string according to a date format and the default locale
 */
+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat;

/** Returns a date from a string according to a date format and a specified locale identifier
 */
+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

/** 
 */
- (NSDate *)dateFromTimeZone:(NSTimeZone *)sourceTimeZone toTimeZone:(NSTimeZone *)destinationTimeZone;

/** Returns a date from an ISO8601 UTC "time point" string (yyyy-MM-dd'T'HH:mm:ss'Z')
 */
+ (NSDate *)dateFromStringWithISO8601TimePointFormat:(NSString *)string;


///-----------------------------------
/// @name Representing Dates as Strings
///-----------------------------------

/** Formats the date according to a format and in specified locale identifier
 */
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

/**  Formats the date according to a format and in default locale
 */
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat;

/** Formats the date as string using the specified "date format" in the specified locale identifier
 */
- (NSString *)stringWithDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

/** Formats the date as string using the specified "date format" in the current locale
 */
- (NSString *)stringWithDateFormat:(NSString *)dateFormat;

/** Formats the date and time using NSDateFormatterStyle
 */
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)inTimeStyle;

/** Formats the date as a ISO8601 UTC "time point" minimal string (yyyyMMdd'T'HHmmss'Z')
 */
- (NSString *)stringWithISO8601TimePointMinimalFormat;

///-----------------------------------
/// @name Getting Date using TimeZone
///-----------------------------------

/** 
 */
- (NSDate *)localDate;

/** 
 */
- (NSDate *)UTCDate;


@end
