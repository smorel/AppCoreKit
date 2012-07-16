//
//  CKNSMutableDictionary+CKObjectPropertyMetaData.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSMutableDictionary+CKObjectPropertyMetaData.h"

//NSNumbers
NSString* CKObjectPropertyMetaDataMinValue = @"CKObjectPropertyMetaDataMinValue";
NSString* CKObjectPropertyMetaDataMaxValue = @"CKObjectPropertyMetaDataMaxValue";
//TextFields/textViews
NSString* CKObjectPropertyMetaDataMinLength = @"CKObjectPropertyMetaDataMinLength";
NSString* CKObjectPropertyMetaDataMaxLength = @"CKObjectPropertyMetaDataMaxLength";

@implementation NSMutableDictionary (CKObjectPropertyMetaData)

//NSNumber
- (void)setMinimumValue:(NSNumber*)value{
    [self setObject:value forKey:CKObjectPropertyMetaDataMinValue];
}

- (void)setMaximumValue:(NSNumber*)value{
    [self setObject:value forKey:CKObjectPropertyMetaDataMaxValue];
}

- (NSNumber*)minimumValue{
    return [self objectForKey:CKObjectPropertyMetaDataMinValue];
}

- (NSNumber*)maximumValue{
    return [self objectForKey:CKObjectPropertyMetaDataMaxValue];
}

//textField/textView
- (void)setMinimumLength:(NSInteger)length{
    [self setObject:[NSNumber numberWithInt:length] forKey:CKObjectPropertyMetaDataMinLength];
}

- (void)setMaximumLength:(NSInteger)length{
    [self setObject:[NSNumber numberWithInt:length] forKey:CKObjectPropertyMetaDataMaxLength];
}

- (NSInteger)minimumLength{
    NSNumber* n = [self objectForKey:CKObjectPropertyMetaDataMinLength];
    return n ? [n intValue] : -1;
}

- (NSInteger)maximumLength{
    NSNumber* n = [self objectForKey:CKObjectPropertyMetaDataMaxLength];
    return n ? [n intValue] : -1;
}

@end
