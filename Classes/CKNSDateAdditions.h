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


- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateByAddingWeeks:(NSInteger)weeks;
	

// Returns a date from a RFC2445 compliant string
+ (NSDate *)dateFromRFC2445:(NSString *)time;

// Returns a date from a time as "HH:mm"
+ (NSDate *)dateFromTime:(NSString *)time;

// Returns a date from a string according to a format
+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat;

//
// Date string formatters
//

// Formats the date according to a format
+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat;

// TODO
- (NSString *)stringFromDateFormat:(NSString *)dateFormat;

// Formats the date as a RFC2445 compliant string
- (NSString *)formatRFC2445;

// Formats the date as "yy-dd-mm"
- (NSString *)formatDateShort;

// Formats the date as "MMM dd yyyy"
- (NSString *)formatDate;

// Formats the date as "HH:mm"
- (NSString*)formatTime;

// Formats the date as "HHmmss"
- (NSString *)formatTimeRaw;

// Formats the name of the day
- (NSString *)formatDay;

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
