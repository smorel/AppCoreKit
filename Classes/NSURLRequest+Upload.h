//
//  NSURLRequest+Upload.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-22.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSURLRequest (Upload)

///-----------------------------------
/// @name Creating an URL Request
///-----------------------------------

/**
 */
+ (id)requestWithURL:(NSURL *)URL body:(NSData*)body;

@end
