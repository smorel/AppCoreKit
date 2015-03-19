//
//  NSDateFormatter+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-19.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "NSDateFormatter+ValueTransformer.h"

@implementation NSDateFormatter (ValueTransformer)

+ (id)convertFromNSString:(NSString*)string{
    NSDateFormatter* formatter = [[[NSDateFormatter alloc]init]autorelease];
    formatter.dateFormat = string;
    return formatter;
}

@end
