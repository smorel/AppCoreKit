//
//  NSData+SHA1.h
//
//  Created by Fred Brunel on 19/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SHA1)

+ (NSData *)dataWithSHA1EncodedString:(NSString *)string;

@end
