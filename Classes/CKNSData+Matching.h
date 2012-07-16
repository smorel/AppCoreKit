//
//  CKNSData+Matching.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSData (CKNSDataMatching)

- (NSUInteger)indexOfData:(NSData *)data searchRange:(NSRange)searchRange;

@end
