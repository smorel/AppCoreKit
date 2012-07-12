//
//  NSData+Compression.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 */
@interface NSData (CKNSDataCompression)

///-----------------------------------
/// @name Compressing Data
///-----------------------------------

/** 
 */
- (NSData *)inflatedData;

@end
