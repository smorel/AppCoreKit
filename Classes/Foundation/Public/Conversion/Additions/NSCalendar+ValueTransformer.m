//
//  NSCalendar+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-19.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "NSCalendar+ValueTransformer.h"


FOUNDATION_EXPORT NSString * const NSGregorianCalendar NS_CALENDAR_DEPRECATED(10_4, 10_10, 2_0, 8_0, "Use NSCalendarIdentifierGregorian instead");
FOUNDATION_EXPORT NSString * const NSBuddhistCalendar NS_CALENDAR_DEPRECATED(10_4, 10_10, 2_0, 8_0, "Use NSCalendarIdentifierBuddhist instead");
FOUNDATION_EXPORT NSString * const NSChineseCalendar NS_CALENDAR_DEPRECATED(10_4, 10_10, 2_0, 8_0, "Use NSCalendarIdentifierChinese instead");
FOUNDATION_EXPORT NSString * const NSHebrewCalendar NS_CALENDAR_DEPRECATED(10_4, 10_10, 2_0, 8_0, "Use NSCalendarIdentifierHebrew instead");
FOUNDATION_EXPORT NSString * const NSIslamicCalendar NS_CALENDAR_DEPRECATED(10_4, 10_10, 2_0, 8_0, "Use NSCalendarIdentifierIslamic instead");
FOUNDATION_EXPORT NSString * const NSIslamicCivilCalendar NS_CALENDAR_DEPRECATED(10_4, 10_10, 2_0, 8_0, "Use NSCalendarIdentifierIslamicCivil instead");
FOUNDATION_EXPORT NSString * const NSJapaneseCalendar NS_CALENDAR_DEPRECATED(10_4, 10_10, 2_0, 8_0, "Use NSCalendarIdentifierJapanese instead");
FOUNDATION_EXPORT NSString * const NSRepublicOfChinaCalendar NS_CALENDAR_DEPRECATED(10_6, 10_10, 4_0, 8_0, "Use NSCalendarIdentifierRepublicOfChina instead");
FOUNDATION_EXPORT NSString * const NSPersianCalendar NS_CALENDAR_DEPRECATED(10_6, 10_10, 4_0, 8_0, "Use NSCalendarIdentifierPersian instead");
FOUNDATION_EXPORT NSString * const NSIndianCalendar NS_CALENDAR_DEPRECATED(10_6, 10_10, 4_0, 8_0, "Use NSCalendarIdentifierIndian instead");
FOUNDATION_EXPORT NSString * const NSISO8601Calendar NS_CALENDAR_DEPRECATED(10_6, 10_10, 4_0, 8_0, "Use NSCalendarIdentifierISO8601 instead");

@implementation NSCalendar (ValueTransformer)

+ (id)convertFromNSString:(NSString*)string{
    static NSDictionary* predefinedCalendars = nil;
    if(!predefinedCalendars){
        predefinedCalendars = @{
                                @"NSGregorianCalendar" : NSGregorianCalendar,
                                @"NSCalendarIdentifierGregorian" : NSCalendarIdentifierGregorian,
                                @"NSBuddhistCalendar" : NSBuddhistCalendar,
                                @"NSCalendarIdentifierBuddhist" : NSCalendarIdentifierBuddhist,
                                @"NSChineseCalendar" : NSChineseCalendar,
                                @"NSCalendarIdentifierChinese" : NSCalendarIdentifierChinese,
                                @"NSHebrewCalendar" : NSHebrewCalendar,
                                @"NSCalendarIdentifierHebrew" : NSCalendarIdentifierHebrew,
                                @"NSIslamicCalendar" : NSIslamicCalendar,
                                @"NSCalendarIdentifierIslamic" : NSCalendarIdentifierIslamic,
                                @"NSIslamicCivilCalendar" : NSIslamicCivilCalendar,
                                @"NSCalendarIdentifierIslamicCivil" : NSCalendarIdentifierIslamicCivil,
                                @"NSJapaneseCalendar" : NSJapaneseCalendar,
                                @"NSCalendarIdentifierJapanese" : NSCalendarIdentifierJapanese,
                                @"NSRepublicOfChinaCalendar" : NSRepublicOfChinaCalendar,
                                @"NSCalendarIdentifierRepublicOfChina" : NSCalendarIdentifierRepublicOfChina,
                                @"NSPersianCalendar" : NSPersianCalendar,
                                @"NSCalendarIdentifierPersian" : NSCalendarIdentifierPersian,
                                @"NSIndianCalendar" : NSIndianCalendar,
                                @"NSCalendarIdentifierIndian" : NSCalendarIdentifierIndian,
                                @"NSISO8601Calendar" : NSISO8601Calendar,
                                @"NSCalendarIdentifierISO8601" : NSCalendarIdentifierISO8601
        };
    }
    
    NSString* predefined = [predefinedCalendars objectForKey:string];
    return [[[NSCalendar alloc]initWithCalendarIdentifier:predefined ? predefined : string]autorelease];
}

@end
