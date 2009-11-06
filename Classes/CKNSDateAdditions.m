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
	NSString *time = [NSDate stringFromDate:[NSDate date] withDateFormat:@"yyyy-d-M"];
	NSDate *date = [NSDate dateFromString:time withDateFormat:@"yyyy-d-M"];
	return date;
}

- (NSDate*)dateAtMidnight {
	NSString *time = [NSDate stringFromDate:self withDateFormat:@"yyyy-d-M"];
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

+ (NSDate *)dateFromRFC2445:(NSString *)time {
	// RFC2445: Format the date as 20090301T235959
	// TODO IMPORTANT: The parsing is dependant from the locale currently 
	// setup (in the system or in the NSDateFormatter), this format must be dependant
	// on the US locale (i.e. en_US).
	return [NSDate dateFromString:time withDateFormat:@"yyyyMMdd'T'HHmmss"];
}

+ (NSDate *)dateFromTime:(NSString *)time {
	return [NSDate dateFromString:time withDateFormat:@"HH:mm"];
}

//
// Date string formatters
//

+ (NSDateFormatter *)formatterWithDateFormat:(NSString *)dateFormat {
	static NSMutableDictionary *formatters = nil;
	if (formatters == nil) { formatters = [[NSMutableDictionary dictionary] retain]; }
	
	NSDateFormatter *formatter;
	formatter = [formatters objectForKey:dateFormat];
		
	if (formatter == nil) { 
		formatter = [[[NSDateFormatter alloc] init] autorelease];
		formatter.dateFormat = dateFormat;
		
		// Setup the default locale of the formatter
		// FIXME: It should be configurable at the clas level
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[formatter setLocale:usLocale];
		
		[formatters setObject:formatter forKey:dateFormat];
	}
	
	return formatter;
}

+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat {
	return [[NSDate formatterWithDateFormat:dateFormat] dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat {
	return [[NSDate formatterWithDateFormat:dateFormat] stringFromDate:date];
}

- (NSString *)stringFromDateFormat:(NSString *)dateFormat {
	return [NSDate stringFromDate:self withDateFormat:dateFormat];
}

- (NSString *)formatRFC2445 {
	return [self stringFromDateFormat:@"yyyyMMdd'T'HHmmss"]; // RFC2445: Format the date as 20090301T235959
}

- (NSString *)formatDateShort {
	return [self stringFromDateFormat:@"yy-MM-dd"];
}

- (NSString *)formatDate {
	return [self stringFromDateFormat:@"MMM dd yyyy"]; 
}

- (NSString *)formatTime {
	return [self stringFromDateFormat:@"HH:mm"];
}

- (NSString *)formatTimeRaw {
	return [self stringFromDateFormat:@"HHmmss"];
}

- (NSString *)formatDay {
	return [self stringFromDateFormat:@"EEEE"];
}

//
// Date comparisons
//

- (BOOL)isAtMidnight {
	NSString *time = [self stringFromDateFormat:@"HHmmss"];
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
