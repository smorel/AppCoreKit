//
//  NSData+Matching.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSData (CKNSDataMatching)

///-----------------------------------
/// @name Finding Data in a Data
///-----------------------------------

/** 
 */
- (NSUInteger)indexOfData:(NSData *)data searchRange:(NSRange)searchRange;

@end
