//
//  CKWebDataConverter.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-18.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebDataConverter.h"
#import <UIKit/UIKit.h>
#import <VendorsKit/VendorsKit.h>

@implementation CKWebDataConverter

static NSMutableDictionary *dictionnary;

+ (void)initialize {
    dictionnary = [[NSMutableDictionary alloc] init];
    
    [self addConverter:^id(NSData *data, NSURLResponse *response) {
        NSStringEncoding responseEncoding;
        if (response.textEncodingName)
             responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName));
        else 
            responseEncoding = NSUTF8StringEncoding;
        
        return [[[NSString alloc] initWithData:data encoding:responseEncoding] autorelease];
    } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject hasPrefix:@"text/"];
    }]];
    
    [self addConverter:^id(NSData *data, NSURLResponse *response) {
        return [UIImage imageWithData:data];
    } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject hasPrefix:@"image/"];
    }]];
    
    [self addConverter:^id(NSData *data, NSURLResponse *response) {
        return [data objectFromJSONData];
    } forMIMEPredicate:[NSPredicate predicateWithFormat:@"self = \"application/json\""]];
}

+ (void)addConverter:(id (^)(NSData *, NSURLResponse *response))converter forMIMEPredicate:(NSPredicate*)predicate {
    [dictionnary setObject:converter forKey:predicate];
}

+ (id)convertData:(NSData *)data fromResponse:(NSURLResponse *)response {
    NSString *MIMEType = response.MIMEType;
    
    id (^converter)(NSData *) = nil;
    for (NSPredicate *predicate in dictionnary) {
        if ([predicate evaluateWithObject:MIMEType]) {
            converter = [dictionnary objectForKey:predicate];
            break;
        }
    }
    
    if (converter)
        return converter(data);
    else
        return data;
}

@end
