//
//  NSData+SHA1.m
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "NSData+SHA1.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (CKNSDataSHA1Additions)

+ (NSData *)dataWithSHA1EncodedString:(NSString *)string {
	CC_SHA1_CTX sha1;
	UInt8 bytes[20];
	
	CC_SHA1_Init(&sha1);
    
    //ARM64 : Verify the following cast (CC_LONG) is correct !
	CC_SHA1_Update(&sha1, [string UTF8String], (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    
	CC_SHA1_Final(&(bytes[0]), &sha1);
	
	return [NSData dataWithBytes:&bytes length:20];
}

+ (NSData *)dataWithMD5EncodedString:(NSString *)string {
	CC_MD5_CTX md5;
	UInt8 digest[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5_Init(&md5);
    
    //ARM64 : Verify the following cast (CC_LONG) is correct !
	CC_MD5_Update(&md5, [string UTF8String], (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    
	CC_MD5_Final(digest, &md5);
	
	return [NSData dataWithBytes:&digest length:CC_MD5_DIGEST_LENGTH];
}

//

- (NSString *)hexadecimalRepresentation {
	const unsigned char *bytes = (const unsigned char *)[self bytes];
	NSMutableString *string = [NSMutableString stringWithCapacity:[self length]];
	for (int i = 0; i < [self length]; i++) {
		[string appendFormat:@"%02X", bytes[i]];
	}
	return string;
}

@end
