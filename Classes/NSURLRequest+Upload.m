//
//  NSURLRequest+Upload.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-22.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "NSURLRequest+Upload.h"

@implementation NSURLRequest (Upload)

+ (id)requestWithURL:(NSURL *)URL body:(NSData *)body {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:URL] autorelease];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    return request;
}

@end
