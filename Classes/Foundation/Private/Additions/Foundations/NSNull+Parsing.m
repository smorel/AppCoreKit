//
//  NSNull+Parsing.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "NSNull+Parsing.h"

@implementation NSNull (Parsing)

//This helps unpacking json by removing the need of testing if we have an NSNull value instead of a dictionary

- (id)objectForKey:(NSString*)key{
    return nil;
}

@end
