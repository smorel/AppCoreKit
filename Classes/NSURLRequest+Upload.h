//
//  NSURLRequest+Upload.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-22.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Upload)

+ (id)requestWithURL:(NSURL *)URL toUploadData:(NSData*)data;

@end
