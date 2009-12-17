//
//  CKNSDateAdditions.h
//
//  Created by Fred Brunel on 04/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateAdditions)

//
// Date manipulations
//

// Returns the current date with the time set to midnight.
+ (NSDate *)dateWithToday;

// Returns a copy of the date with the time set to midnight on the same day.
- (NSDate *)dateAtMidnight;

// Returns a copy of the date with the time set to 24h earlier.
- (NSDate *)dateAtYesterday;

// Returns a copy of the date with the time set to 24h later.
- (NSDate *)dateAtTomorrow;

// Returns a copy of the date with the time set to 1 week earlier.
- (NSDate *)dateAtPreviousWeek;

// Returns a copy of the date with the time set to 1 week later.
- (NSDate *)dateAtNextWeek;

// Returns a copy of the date with days added
- (NSDate *)dateByAddingDays:(NSInteger)days;

// Returns a copy of the date with weeks added
- (NSDate *)dateByAddingWeeks:(NSInteger)weeks;

// Returns a date from a ISO8601 "time point" string
+ (NSDate *)dateFromISO8601TimePointString:(NSString *)date;

// Returns a date from a time as "HH:mm"
+ (NSDate *)dateFromTimeString:(NSString *)time;

// Returns a date from a string according to a date format and the default locale
+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat;

// Returns a date from a string according to a date format and a specified locale identifier
+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

//
// Date string formatters
//

// Formats the date according to a format and in specified locale identifier
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

// Formats the date according to a format and in default locale
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat;

// Formats the date as string using the specified "date format" in the specified locale identifier
- (NSString *)stringWithDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier;

// Formats the date as string using the specified "date format" in the current locale
- (NSString *)stringWithDateFormat:(NSString *)dateFormat;

// Formats the date as a ISO8601 "time point" string
- (NSString *)stringWithISO8601TimePointFormat;

// Formats the date as "yy-dd-mm"
- (NSString *)stringWithDateShortFormat;

// Formats the date as "MMM dd yyyy"
- (NSString *)stringWithDateFormat;

// Formats the date as "HH:mm"
- (NSString*)stringWithTimeFormat;

// Formats the date as "HHmmss"
- (NSString *)stringWithRawTimeFormat;

// Formats the name of the day
- (NSString *)stringWithDayFormat;

//
// Date comparisons
//

// Returns TRUE is the date time is set at midnight
- (BOOL)isAtMidnight;

// Returns TRUE if the receiver is earlier another given date
- (BOOL)isEarlier:(NSDate *)anotherDate;

// Returns the interval between the receiver and another given date expressed in hours.
- (double)timeIntervalSinceDateInHours:(NSDate *)anotherDate;

// Returns TRUE if the receiver is between to dates
- (BOOL)isBetweenDate:(NSDate *)startDate andDate:(NSDate *)endDate;

@end