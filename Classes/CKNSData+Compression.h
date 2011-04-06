//
//  CKNSData+Compression.h
//  CloudKit
//
//  Created by Fred Brunel on 11-02-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CKNSDataCompression)

- (NSData *)inflatedData;

@end
