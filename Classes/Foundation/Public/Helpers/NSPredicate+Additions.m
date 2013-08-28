//
//  NSPredicate+Addition.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSPredicate+Additions.h"

//FIXME : use predicate with format when possible.
@implementation NSPredicate (CKNSPredicateAdditions)

+ (NSPredicate*)predicateForFloatInRange:(NSRange)range{
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if(!evaluatedObject || ![evaluatedObject isKindOfClass:[NSNumber class]])
            return NO;
        NSNumber* number = (NSNumber*)evaluatedObject;
        CGFloat value = [number floatValue];
        return (BOOL)(value >= range.location && value <= range.location + range.length);
    }];
}

+ (NSPredicate*)predicateForValidString{
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if(!evaluatedObject || ![evaluatedObject isKindOfClass:[NSString class]] || [evaluatedObject length] <= 0)
            return NO;
        return YES;
    }];
}

+ (NSPredicate*)predicateForValidStringWithMaximumLength:(NSUInteger)length{
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if(!evaluatedObject || ![evaluatedObject isKindOfClass:[NSString class]] || [evaluatedObject length] <= 0
           || [evaluatedObject length] >= length)
            return NO;
        return YES;
    }];
}

@end
