//
//  CKStyle+Parsing.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NSDictionary* CKEnumDictionaryFunc(NSString* strValues, ...);
#define CKEnumDictionary(...) CKEnumDictionaryFunc([NSString stringWithUTF8String:#__VA_ARGS__],__VA_ARGS__)

@interface CKStyleParsing : NSObject {
}

+ (NSInteger)parseString:(NSString*)str toEnum:(NSDictionary*)keyValues;
+ (UIColor*)parseStringToColor:(NSString*)str;
+ (CGSize)parseStringToCGSize:(NSString*)str;

@end
