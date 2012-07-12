//
//  NSDate+Calculations.m
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "NSDate+Calculations.h"
#import "NSDate+Conversions.h"

@implementation NSDate (NSDateCalculationsAdditions)

- (NSDate*)dateAtBeginningOfDay {
	NSString *time = [self stringWithDateFormat:@"yyyy-d-M"];
	NSDate *date = [NSDate dateFromString:time withDateFormat:@"yyyy-d-M"];
	return date;	
}

- (NSDate *)dateAtYesterday {
	return [self dateByAdvancingDays:-1];
}

- (NSDate *)dateAtTomorrow {
	return [self dateByAdvancingDays:1];
}

- (NSDate *)dateAtLastWeek {
	return [self dateByAdvancingWeeks:-1];
}

- (NSDate *)dateAtNextWeek {
	return [self dateByAdvancingWeeks:1];
}

- (NSDate *)dateByAdvancingDays:(NSInteger)days {
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setDay:days];
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)dateByAdvancingWeeks:(NSInteger)weeks {
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setWeek:weeks];
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

- (BOOL)isAtBeginningOfDay {
	NSString *time = [self stringWithDateFormat:@"HHmmss"];
	return [time isEqualToString:@"000000"];
}

- (BOOL)isBefore:(NSDate *)date {
	return ([self timeIntervalSinceDate:date] < 0);
}

- (double)timeIntervalSinceDateInHours:(NSDate *)anotherDate {
	return ([self timeIntervalSinceDate:anotherDate] / 60.0 / 60.0);
}

- (BOOL)isBetweenDate:(NSDate *)startDate andDate:(NSDate *)endDate {
	NSTimeInterval interval = [self timeIntervalSince1970];
	return ((interval > [startDate timeIntervalSince1970]) && (interval < [endDate timeIntervalSince1970]));
}

@end
