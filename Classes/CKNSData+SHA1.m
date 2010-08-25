//
//  CKNSData+SHA1.m
//
//  Created by Fred Brunel on 19/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSData+SHA1.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (CKNSDataSHA1Additions)

+ (NSData *)dataWithSHA1EncodedString:(NSString *)string {
	CC_SHA1_CTX sha1;
	UInt8 bytes[20];
	
	CC_SHA1_Init(&sha1);
	CC_SHA1_Update(&sha1, [string UTF8String], [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
	CC_SHA1_Final(&(bytes[0]), &sha1);
	
	return [NSData dataWithBytes:&bytes length:20];
}

- (NSString *)hexadecimalRepresentation {
	const unsigned char *bytes = (const unsigned char *)[self bytes];
	NSMutableString *string = [NSMutableString stringWithCapacity:[self length]];
	for (int i = 0; i < [self length]; i++) {
		[string appendFormat:@"%02X", bytes[i]];
	}
	return string;
}

@end
