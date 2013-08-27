//
//  NSURLRequest+Upload.h
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSURLRequest (Upload)

///-----------------------------------
/// @name Creating an URL Request
///-----------------------------------

/**
 */
+ (id)requestWithURL:(NSURL *)URL body:(NSData*)body;

@end
