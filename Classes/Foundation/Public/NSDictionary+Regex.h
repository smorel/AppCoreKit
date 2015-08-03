//
//  NSDictionary+Regex.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-08-03.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Regex)

- (NSDictionary*)dictionaryForKeysMatchingRegularExpression:(NSRegularExpression*)regex;
- (NSArray*)objectsForKeysMatchingRegularExpression:(NSRegularExpression*)regex;

@end
