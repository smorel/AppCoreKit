//
//  CKNSDate+Conversions.m
//
//  Created by Fred Brunel on 09-12-17.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSDate+Conversions.h"

@implementation NSDate (CKNSDateConversionsAdditions)

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

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)timeStyle {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateStyle = dateStyle;
	formatter.timeStyle = timeStyle;
	return [formatter stringFromDate:self];
}

//
// Date minimal ISO8601
//

- (NSString *)stringWithISO8601TimePointFormat {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"yyyyMMdd'T'HHmmss'Z'";
	formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	return [formatter stringFromDate:self];
}

@end
