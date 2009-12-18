//
//  CKNSDate+Conversions.h
//
//  Created by Fred Brunel on 09-12-17.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CKNSDateConversionsAdditions)

// Returns a date from a string according to a date format and the default locale
+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat;

// Returns a date from a string according to a date format and a specified locale identifier
+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

// Formats the date according to a format and in specified locale identifier
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

// Formats the date according to a format and in default locale
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat;

// Formats the date as string using the specified "date format" in the specified locale identifier
- (NSString *)stringWithDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

// Formats the date as string using the specified "date format" in the current locale
- (NSString *)stringWithDateFormat:(NSString *)dateFormat;

// TODO: These formats should be deprecated, it's up to the application to define the formats
// TODO: These formats should be replaced by the locale-specific defaults formats from the OS
//       NSDateFormatterStyle & NSDateFormatterStyle

//
// Date formats
//

// Formats the date as "yy-dd-mm"
- (NSString *)stringWithDateShortFormat DEPRECATED_ATTRIBUTE; 

// Formats the date as "MMM dd yyyy"
- (NSString *)stringWithDateFormat DEPRECATED_ATTRIBUTE;

// Formats the date as "HH:mm"
- (NSString*)stringWithTimeFormat DEPRECATED_ATTRIBUTE;

// Formats the date as "HHmmss"
- (NSString *)stringWithRawTimeFormat DEPRECATED_ATTRIBUTE;

// Formats the name of the day
- (NSString *)stringWithDayFormat DEPRECATED_ATTRIBUTE;

//
// Date minimal ISO8601
//

// Returns a date from a ISO8601 "time point" string
+ (NSDate *)dateFromISO8601TimePointString:(NSString *)date;

// TODO: This format should be put in a separate addition
// Formats the date as a ISO8601 "time point" string
- (NSString *)stringWithISO8601TimePointFormat;

@end
