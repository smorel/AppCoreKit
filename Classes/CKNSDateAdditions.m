//
//  CKNSDateAdditions.m
//
//  Created by Fred Brunel on 04/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSDateAdditions.h"

@implementation NSDate (CKNSDateAdditions)

//
// Date manipulations
//

+ (NSDate*)dateWithToday {
	NSString *time = [[NSDate date] stringWithDateFormat:@"yyyy-d-M"];
	NSDate *date = [NSDate dateFromString:time withDateFormat:@"yyyy-d-M"];
	return date;
}

- (NSDate*)dateAtMidnight {
	NSString *time = [self stringWithDateFormat:@"yyyy-d-M"];
	NSDate *date = [NSDate dateFromString:time withDateFormat:@"yyyy-d-M"];
	return date;	
}

- (NSDate *)dateAtYesterday {
	return [self dateByAddingDays:-1];
}

- (NSDate *)dateAtTomorrow {
	return [self dateByAddingDays:1];
}

- (NSDate *)dateAtPreviousWeek {
	return [self dateByAddingWeeks:-1];
}

- (NSDate *)dateAtNextWeek {
	return [self dateByAddingWeeks:1];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setDay:days];
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self  options:0];
}

- (NSDate *)dateByAddingWeeks:(NSInteger)weeks {
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setWeek:weeks];
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self  options:0];
}

+ (NSDate *)dateFromISO8601TimePointString:(NSString *)time {
	// ISO8601: Format the date as 20090301T235959
	// NOTE: this format must be dependant on the US locale (i.e. en_US).
	// TODO: append 'Z' if the time zone is UTC
	return [NSDate dateFromString:time withDateFormat:@"yyyyMMdd'T'HHmmss" forLocaleIdentifier:@"en_US"];
}

+ (NSDate *)dateFromTimeString:(NSString *)time {
	return [NSDate dateFromString:time withDateFormat:@"HH:mm"];
}

//
// Date string formatters
//

// TODO: Move this in a NSDateFormatter Addition
// NOTE: This method maintains a cache of NSDateFormatters

+ (NSDateFormatter *)formatterWithDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
	static NSMutableDictionary *formatters = nil;
	if (formatters == nil) { formatters = [[NSMutableDictionary dictionary] retain]; }
	
	NSLocale *locale = localeIdentifier 
	  ? [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier]
	  : [NSLocale currentLocale];
	
	NSString *key = [NSString stringWithFormat:@"%@-%@", dateFormat, locale.localeIdentifier];
	NSDateFormatter *formatter = [formatters objectForKey:key];
	
	if (formatter == nil) { 
		formatter = [[[NSDateFormatter alloc] init] autorelease];
		formatter.formatterBehavior = NSDateFormatterBehavior10_4;
		formatter.dateFormat = dateFormat;
		formatter.locale = locale;
		[formatters setObject:formatter forKey:key];
	}
	
	return formatter;
}

+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
	return [[NSDate formatterWithDateFormat:dateFormat forLocaleIdentifier:localeIdentifier] dateFromString:string];
}

+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat {
	return [NSDate dateFromString:string withDateFormat:dateFormat forLocaleIdentifier:nil];
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
	return [[NSDate formatterWithDateFormat:dateFormat forLocaleIdentifier:localeIdentifier] stringFromDate:date];
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat {
	return [NSDate stringFromDate:date withDateFormat:dateFormat forLocaleIdentifier:nil];
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
	return [NSDate stringFromDate:self withDateFormat:dateFormat forLocaleIdentifier:localeIdentifier];
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat {
	return [NSDate stringFromDate:self withDateFormat:dateFormat];
}

- (NSString *)stringWithISO8601TimePointFormat {
	// ISO8601: Parse the date as 20090301T235959
	// See -dateFromISO8601String
	return [self stringWithDateFormat:@"yyyyMMdd'T'HHmmss" forLocaleIdentifier:@"en_US"];
}

- (NSString *)stringWithDateShortFormat {
	return [self stringWithDateFormat:@"yy-MM-dd"];
}

- (NSString *)stringWithDateFormat {
	return [self stringWithDateFormat:@"MMM dd yyyy"]; 
}

- (NSString *)stringWithTimeFormat {
	return [self stringWithDateFormat:@"HH:mm"];
}

- (NSString *)stringWithRawTimeFormat {
	return [self stringWithDateFormat:@"HHmmss"];
}

- (NSString *)stringWithDayFormat {
	return [self stringWithDateFormat:@"EEEE"];
}

//
// Date comparisons
//

- (BOOL)isAtMidnight {
	NSString *time = [self stringWithDateFormat:@"HHmmss"];
	return [time isEqualToString:@"000000"];
}

- (BOOL)isEarlier:(NSDate *)anotherDate {
	return ([self timeIntervalSinceDate:anotherDate] < 0);
}

- (double)timeIntervalSinceDateInHours:(NSDate *)anotherDate {
	return ([self timeIntervalSinceDate:anotherDate] / 60.0 / 60.0);
}

- (BOOL)isBetweenDate:(NSDate *)startDate andDate:(NSDate *)endDate {
	NSTimeInterval interval = [self timeIntervalSince1970];
	return ((interval > [startDate timeIntervalSince1970]) && (interval < [endDate timeIntervalSince1970]));
}

@end