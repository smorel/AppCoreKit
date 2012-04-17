//
//  CKMultipartEncoder.m
//  CKMultipartEncoder
//
//  Created by Fred Brunel on 11-06-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKMultipartEncoder.h"
#import "CKNSString+Additions.h"

@implementation CKMultipartEncoder

- (void)dealloc {
	[_bodyData release];
	[_partBoundary release];
	[_endBoundary release];
	[_contentType release];
	[super dealloc];
}

- (NSString *)contentType {
	return _contentType;
}

//

- (void)prepare {
	if (_boundary == nil) {
		_bodyData = [[NSMutableData alloc] init];
		NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
		_boundary = [[NSString stringWithNewUUID] retain];
		_contentType = [[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, _boundary] retain];
		_partBoundary = [[[NSString stringWithFormat:@"\r\n--%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding] retain];
		_endBoundary = [[[NSString stringWithFormat:@"\r\n--%@--\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding] retain];
	}
}

- (void)appendData:(NSData *)data {
	[_bodyData appendData:data];
}

- (void)appendString:(NSString *)string {
	[self appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendContentDispositionForName:(NSString *)key fileName:(NSString *)fileName contentType:(NSString *)contentType {
	[self prepare];
	[self appendData:_partBoundary];
	
	if (fileName) {
		[self appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, fileName]];
	} else {
		[self appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key]];
	}
	
	if (contentType) {
		[self appendString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType]];
	} else {
		[self appendString:@"Content-Type: text/plain\r\n\r\n"];
	}
}

//

- (NSData *)finalizedData {
	if (_bodyData == nil)
		return nil;
	
	NSMutableData *finalizedData = [NSMutableData dataWithData:_bodyData];
	[finalizedData appendData:_endBoundary];
	return finalizedData;
}

- (void)addFieldWithValue:(NSString *)value forName:(NSString *)name contentType:(NSString *)contentType {
	[self appendContentDispositionForName:name fileName:nil contentType:contentType];
	[self appendString:value];
}

- (void)addFileWithData:(NSData *)data forName:(NSString *)name fileName:(NSString *)fileName contentType:(NSString *)contentType {
	[self appendContentDispositionForName:name fileName:fileName contentType:contentType];
	[self appendData:data];
}

- (void)addFileWithData:(NSData *)data forName:(NSString *)name contentType:(NSString *)contentType {
	[self addFileWithData:data forName:name fileName:[NSString stringWithNewUUID] contentType:contentType];
}

@end
