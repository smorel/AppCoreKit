//
//  NSDictionary+Regex.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-08-03.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "NSDictionary+Regex.h"

@implementation NSDictionary (Regex)

- (NSDictionary*)dictionaryForKeysMatchingRegularExpression:(NSRegularExpression*)regex{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for(id key in [self allKeys]){
        if(![key isKindOfClass:[NSString class]])
            continue;
        
        NSArray* matches = [regex matchesInString:key options:0 range:NSMakeRange(0, [key length])];
        if(matches.count > 0){
            [result setObject:[self objectForKey:key] forKey:key];
        }
    }
    
    return result;
}

- (NSArray*)objectsForKeysMatchingRegularExpression:(NSRegularExpression*)regex{
    return [[self dictionaryForKeysMatchingRegularExpression:regex]allValues];
}

@end
