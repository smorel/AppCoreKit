//
//  NSURLRequest+Upload.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-22.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "NSURLRequest+Upload.h"

@implementation NSURLRequest (Upload)

+ (id)requestWithURL:(NSURL *)URL toUploadData:(NSData *)data {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    return request;
}

@end
