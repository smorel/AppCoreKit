//
//  NSData+Compression.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "NSData+Compression.h"
#import <zlib.h>

@implementation NSData (CKNSDataCompression)

- (NSData *)inflatedData {
	if ([self length] == 0) return self;
	
	NSUInteger fullLength = [self length];
	NSUInteger halfLength = [self length] / 2;
	
	NSMutableData *decompressed = [NSMutableData dataWithLength:(fullLength + halfLength)];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
    
    //ARM64 : Verify the following cast is correct !
	strm.avail_in = (uInt)[self length];
    
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	// TODO: Support zlib format with the following initialization
	// if (inflateInit(&strm) != Z_OK) return nil;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
	
	while (!done) {
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy:halfLength];
		
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
        
        //ARM64 : Verify the following cast is correct !
		strm.avail_out = (uInt)([decompressed length] - strm.total_out);
		
		// Inflate another chunk.
		status = inflate(&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	
	if (inflateEnd(&strm) != Z_OK) return nil;
	
	// Set real length.
	if (done) {
		[decompressed setLength:strm.total_out];
		return [NSData dataWithData:decompressed];
	}
	
	return nil;
}

@end
