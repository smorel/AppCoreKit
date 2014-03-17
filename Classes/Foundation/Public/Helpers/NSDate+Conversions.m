//
//  NSDate+Conversions.m
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "NSDate+Conversions.h"
#import "CKLocalizationManager.h"

@implementation NSDate (CKNSDateConversionsAdditions)

// TODO: Move this in a NSDateFormatter Addition
// NOTE: This method maintains a cache of NSDateFormatters

+ (NSDateFormatter *)formatterWithDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
    static NSMutableDictionary *formattersPerThread = nil;
    if(!formattersPerThread){
        formattersPerThread = [[NSMutableDictionary alloc] init];
    }
    
    NSDateFormatter *formatter = nil;
    @synchronized(formattersPerThread){
        NSThread* currentThread = [NSThread currentThread];
        
        NSMutableDictionary *formatters = [formattersPerThread objectForKey:[NSValue valueWithNonretainedObject:currentThread]];
        if (formatters == nil) {
            formatters = [NSMutableDictionary dictionary];
            [formattersPerThread setObject:formatters forKey:[NSValue valueWithNonretainedObject:currentThread]];
        }
        
        NSLocale *locale = localeIdentifier
	    ? [[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier] autorelease]
	    : [NSLocale currentLocale];
        
        NSString *key = [NSString stringWithFormat:@"%@-%@", dateFormat, locale.localeIdentifier];
        formatter = [formatters objectForKey:key];
        
        if (formatter == nil) {
            formatter = [[[NSDateFormatter alloc] init] autorelease];
            formatter.formatterBehavior = NSDateFormatterBehavior10_4;
            formatter.dateFormat = dateFormat;
            formatter.locale = locale;
            [formatters setObject:formatter forKey:key];
        }
    }
	
	return formatter;
}

+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
	return [[NSDate formatterWithDateFormat:dateFormat forLocaleIdentifier:localeIdentifier] dateFromString:string];
}

+ (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat {
	return [NSDate dateFromString:string withDateFormat:dateFormat forLocaleIdentifier:[[CKLocalizationManager sharedManager]language] ];
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
	return [[NSDate formatterWithDateFormat:dateFormat forLocaleIdentifier:localeIdentifier] stringFromDate:date];
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat {
	return [NSDate stringFromDate:date withDateFormat:dateFormat forLocaleIdentifier:[[CKLocalizationManager sharedManager]language] ];
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat forLocaleIdentifier:(NSString *)localeIdentifier {
	return [NSDate stringFromDate:self withDateFormat:dateFormat forLocaleIdentifier:localeIdentifier];
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat {
	return [NSDate stringFromDate:self withDateFormat:dateFormat];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)timeStyle {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateStyle = dateStyle;
	formatter.timeStyle = timeStyle;
	return [formatter stringFromDate:self];
}

// TimeZone conversions

- (NSDate *)dateFromTimeZone:(NSTimeZone *)sourceTimeZone toTimeZone:(NSTimeZone *)destinationTimeZone {
	NSInteger sourceOffset = [sourceTimeZone secondsFromGMTForDate:self];
	NSInteger destinationOffset = [destinationTimeZone secondsFromGMTForDate:self];
	NSTimeInterval interval = destinationOffset - sourceOffset;
	return [[[NSDate alloc] initWithTimeInterval:interval sinceDate:self] autorelease];
}

- (NSDate *)localDate {
	return [self dateFromTimeZone:[NSTimeZone timeZoneWithName:@"UTC"] toTimeZone:[NSTimeZone systemTimeZone]];
}

- (NSDate *)UTCDate {
	return [self dateFromTimeZone:[NSTimeZone systemTimeZone] toTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

//
// Date minimal ISO8601
//

+ (NSDate *)dateFromStringWithISO8601TimePointFormat:(NSString *)string {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	return [formatter dateFromString:string];
}

- (NSString *)stringWithISO8601TimePointMinimalFormat {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	formatter.dateFormat = @"yyyyMMdd'T'HHmmss'Z'";
	return [formatter stringFromDate:self];
}


- (NSString *)stringWithISO8601TimePointFormat {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	return [formatter stringFromDate:self];
}

@end
