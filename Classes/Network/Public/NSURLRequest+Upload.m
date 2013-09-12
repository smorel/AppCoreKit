//
//  NSURLRequest+Upload.m
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "NSURLRequest+Upload.h"

@implementation NSURLRequest (Upload)

+ (id)requestWithURL:(NSURL *)URL body:(NSData *)body {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:URL] autorelease];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    return request;
}

@end
