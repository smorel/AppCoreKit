//
//  CKNSMutableDictionary+CKPropertyExtendedAttributes.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-23.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSMutableDictionary+CKPropertyExtendedAttributes.h"

//NSNumbers
NSString* CKPropertyExtendedAttributesMinValue = @"CKPropertyExtendedAttributesMinValue";
NSString* CKPropertyExtendedAttributesMaxValue = @"CKPropertyExtendedAttributesMaxValue";
//TextFields/textViews
NSString* CKPropertyExtendedAttributesMinLength = @"CKPropertyExtendedAttributesMinLength";
NSString* CKPropertyExtendedAttributesMaxLength = @"CKPropertyExtendedAttributesMaxLength";

@implementation NSMutableDictionary (CKPropertyExtendedAttributes)

//NSNumber
- (void)setMinimumValue:(NSNumber*)value{
    [self setObject:value forKey:CKPropertyExtendedAttributesMinValue];
}

- (void)setMaximumValue:(NSNumber*)value{
    [self setObject:value forKey:CKPropertyExtendedAttributesMaxValue];
}

- (NSNumber*)minimumValue{
    return [self objectForKey:CKPropertyExtendedAttributesMinValue];
}

- (NSNumber*)maximumValue{
    return [self objectForKey:CKPropertyExtendedAttributesMaxValue];
}

//textField/textView
- (void)setMinimumLength:(NSInteger)length{
    [self setObject:[NSNumber numberWithInt:length] forKey:CKPropertyExtendedAttributesMinLength];
}

- (void)setMaximumLength:(NSInteger)length{
    [self setObject:[NSNumber numberWithInt:length] forKey:CKPropertyExtendedAttributesMaxLength];
}

- (NSInteger)minimumLength{
    NSNumber* n = [self objectForKey:CKPropertyExtendedAttributesMinLength];
    return n ? [n intValue] : -1;
}

- (NSInteger)maximumLength{
    NSNumber* n = [self objectForKey:CKPropertyExtendedAttributesMaxLength];
    return n ? [n intValue] : -1;
}

@end
