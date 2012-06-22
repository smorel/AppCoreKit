//
//  CKNSData+Matching.h
//  CloudKit
//
//  Created by Fred Brunel on 10-07-21.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSData (CKNSDataMatching)

///-----------------------------------
/// @name Finding Data in a Data
///-----------------------------------

/** 
 */
- (NSUInteger)indexOfData:(NSData *)data searchRange:(NSRange)searchRange;

@end
