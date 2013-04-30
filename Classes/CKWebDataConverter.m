//
//  CKWebDataConverter.m
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebDataConverter.h"
#import <UIKit/UIKit.h>
#import "CXMLDocument.h"
#import <VendorsKit/VendorsKit.h>
#import "RegexKitLite.h"

@implementation CKWebDataConverter

static NSMutableDictionary *dictionnary;

static dispatch_once_t onceToken;
static dispatch_group_t group;  

+ (void)initialize {
    dispatch_once(&onceToken, ^{
        dictionnary = [[NSMutableDictionary alloc] init];
    });
    
    group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_current_queue(), ^{
        [self addConverter:^id(NSData *data, NSURLResponse *response, NSError** error) {
            NSStringEncoding responseEncoding;
            if (response.textEncodingName)
                responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName));
            else 
                responseEncoding = NSUTF8StringEncoding;
            
            return [[[NSString alloc] initWithData:data encoding:responseEncoding] autorelease];
        } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject hasPrefix:@"text/"];
        }]];
        
        [self addConverter:^id(NSData *data, NSURLResponse *response, NSError** error) {
            UIImage* temp =  [UIImage imageWithData:data];
            return [[[UIImage alloc]initWithCGImage:temp.CGImage scale:[[UIScreen mainScreen]scale] orientation:temp.imageOrientation]autorelease];
        } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject hasPrefix:@"image/"];
        }]];
        
        [self addConverter:^id(NSData *data, NSURLResponse *response, NSError** error) {
            id object = [data objectFromJSONDataWithParseOptions:JKParseOptionValidFlags error:error];
            return object;
        } forMIMEPredicate:[NSPredicate predicateWithFormat:@"self = \"application/json\""]];
        
        [self addConverter:^id(NSData *data, NSURLResponse *response, NSError** error) {
            return [[[CXMLDocument alloc] initWithData:data options:0 error:error] autorelease];
        } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isMatchedByRegex:@"(application|text)/xml"];
        }]];
    });
}

+ (void)addConverter:(id (^)(NSData * data, NSURLResponse *response, NSError** error))converter forMIMEPredicate:(NSPredicate*)predicate {
    dispatch_once(&onceToken, ^{
        dictionnary = [[NSMutableDictionary alloc] init];
    });
    
    [dictionnary setObject:converter forKey:predicate];
}

+ (id)convertData:(NSData *)data fromResponse:(NSURLResponse *)response error:(NSError**)error {
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    if (data == nil)
        return nil;
    
    NSString *MIMEType = response.MIMEType;
    
    id (^converter)(NSData *, NSURLResponse*, NSError**) = nil;
    for (NSPredicate *predicate in dictionnary) {
        if ([predicate evaluateWithObject:MIMEType]) {
            converter = [dictionnary objectForKey:predicate];
            break;
        }
    }
    
    if (converter) {
        id result = converter(data, response,error);
        if (result)
            return result;
        else
            return data;
    }
    else
        return data;
}

@end
