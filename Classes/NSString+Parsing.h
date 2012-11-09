//
//  NSString+Parsing.h
//  AppCoreKit
//
//  Created by Jean-Philippe Martin.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSString (Parsing) 

///-----------------------------------
/// @name Parsing String Content
///-----------------------------------

/** 
 */
- (NSString *)stringByDeletingHTMLTags;

/** 
 */
- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet*)set;

@end
