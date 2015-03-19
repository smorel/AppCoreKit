//
//  NSLocale+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-19.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "NSLocale+ValueTransformer.h"

@implementation NSLocale (ValueTransformer)

+ (id)convertFromNSString:(NSString*)string{
    return [NSLocale localeWithLocaleIdentifier:string];
}

@end
