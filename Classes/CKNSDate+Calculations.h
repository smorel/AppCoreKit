//
//  CKNSDate+Calculations.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSDate (NSDateCalculationsAdditions)

// Returns a copy of the date with the time set to midnight on the same day.
- (NSDate *)dateAtBeginningOfDay;

// Returns a copy of the date with the time set to 24h earlier.
- (NSDate *)dateAtYesterday;

// Returns a copy of the date with the time set to 24h later.
- (NSDate *)dateAtTomorrow;

// Returns a copy of the date with the time set to 1 week earlier.
- (NSDate *)dateAtLastWeek;

// Returns a copy of the date with the time set to 1 week later.
- (NSDate *)dateAtNextWeek;

// Returns a copy of the date with days added
- (NSDate *)dateByAdvancingDays:(NSInteger)days;

// Returns a copy of the date with weeks added
- (NSDate *)dateByAdvancingWeeks:(NSInteger)weeks;

// Returns TRUE is the date time is set at midnight
- (BOOL)isAtBeginningOfDay;

// Returns TRUE if the receiver is before another given date
- (BOOL)isBefore:(NSDate *)date;

// Returns the interval between the receiver and another given date expressed in hours.
- (double)timeIntervalSinceDateInHours:(NSDate *)anotherDate;

// Returns TRUE if the receiver is between to dates
- (BOOL)isBetweenDate:(NSDate *)startDate andDate:(NSDate *)endDate;

@end
