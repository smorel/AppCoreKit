//
//  CKMultipartParser.m
//  CloudKit
//
//  Created by Fred Brunel on 10-07-21.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKMultipartParser.h"
#import "CKNSData+Matching.h"

@implementation CKMultipartParser

- (id)initWithData:(NSData *)data boundary:(NSString *)boundary {
	[super init];
	
	buffer = [data retain];
	
	UInt16 fsBytes = 0x0A0D;
	fieldSeparator = [[NSData dataWithBytes:&fsBytes length:2] retain];
	
	UInt32 hrBytes = 0x0A0D0A0D;
	headerSeparator = [[NSData dataWithBytes:&hrBytes length:4] retain];
	
	UInt16 stBytes = 0x2D2D;
	streamTerminator = [[NSData dataWithBytes:&stBytes length:2] retain];
	
	// Prepend CR/LF to the boundary separator to chop trailing CR/LF from
	// body data chunks.
	NSMutableData *b = [NSMutableData data];
	[b appendData:fieldSeparator];
	[b appendData:[[NSString stringWithFormat:@"--%@", boundary] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
	boundarySeparator = [b retain];
	
	return self;
}

- (void)dealloc {
	[buffer release];
	[headerSeparator release];
	[fieldSeparator release];
	[streamTerminator release];
	[boundarySeparator release];
	[super dealloc];
}

//

- (NSInteger)findData:(NSData *)data {
	NSRange searchRange = { head, buffer.length - head };
	return [buffer indexOfData:data searchRange:searchRange];
}

- (NSInteger)findBoundarySeparator {
	return [self findData:boundarySeparator];
}

- (NSInteger)findHeaderSeparator {
	return [self findData:headerSeparator];
}

//

- (NSData *)readShort {
	NSRange range = { head, 2 };
	head += 2;
	return [buffer subdataWithRange:range];
}

- (BOOL)skipPreamble {
	NSRange range = { 2, boundarySeparator.length - 2};
	NSData *boundary = [boundarySeparator subdataWithRange:range];
	NSInteger location = [self findData:boundary];
	if (location == NSNotFound)
		return NO;
	head += location + boundary.length;
	NSData *marker = [self readShort];
	if ([marker isEqualToData:fieldSeparator])
		return YES;
	return NO;
}

- (BOOL)readBoundary {
	head += boundarySeparator.length;
	NSData *marker = [self readShort];
	
	if ([marker isEqualToData:streamTerminator]) {
		return NO;
	} else if ([marker isEqualToData:fieldSeparator]) {
		return YES;
	}
	
	NSAssert(nil, @"Error");
	return NO;
}

- (NSData *)readHeadersData {
	NSInteger location = [self findHeaderSeparator];
	NSRange range = { head, location - head };
	NSData *headers = [buffer subdataWithRange:range];
	head += headers.length + 4;
	return headers;
}

- (NSDictionary *)readHeaders {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
	NSString *string = [[[NSString alloc] initWithData:[self readHeadersData] encoding:NSUTF8StringEncoding] autorelease];
	NSArray *headers = [string componentsSeparatedByString:@"\r\n"];
	for (NSString *header in headers) {
		NSArray *kv = [header componentsSeparatedByString:@": "];
		[dictionary setObject:[kv objectAtIndex:1] forKey:[kv objectAtIndex:0]];
	}
	return dictionary;
}

- (NSData *)readBodyData {
	NSInteger location = [self findBoundarySeparator];
	NSAssert(location != NSNotFound, @"Error");
	NSRange range = { head, location - head };
	NSData *body = [buffer subdataWithRange:range];
	head += body.length;
	return body;
}

/*

- (void)parse {	
	BOOL nextChunk = [self skipPreamble];
	while (nextChunk) {
		NSData *headerChunk = [self readHeadersData];
		NSData *bodyChunk = [self readBodyData];
		nextChunk = [self readBoundary];
	}
}

*/
 
@end
