//
//  CKMultipartEncoder.h
//  CKMultipartEncoder
//
//  Created by Fred Brunel on 11-06-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// This class implements a simple "multipart/form-data" builder
// Adds fields and files like for an HTML FORM. 
// The builder generates the contentType and the body data, ready
// to be send via an HTTP request.
//
// Example:
//
// CKMultipartEncoder *multipart = [[CKMultipartEncoder alloc] init];
// [multipart addFieldWithValue:@"foo" forName:@"text1" contentType:@"text/plain"];
// [multipart addFieldWithValue:@"bar" forName:@"text2" contentType:@"text/plain"];
// [multipart addFileWithData:UIImagePNGRepresentation([UIImage imageNamed:@"image.png"]) forName:@"image" fileName:@"image.png" contentType:@"image/png"];
// NSData *data = [multipart finalizedData];


/** TODO
 */
@interface CKMultipartEncoder : NSObject {
	NSString *_contentType;
	NSString *_boundary;
	NSData *_partBoundary;
	NSData *_endBoundary;
	NSMutableData *_bodyData;
}

- (NSString *)contentType;
- (NSData *)finalizedData;

// multipart/form-data

- (void)addFieldWithValue:(NSString *)value forName:(NSString *)name contentType:(NSString *)contentType;
- (void)addFileWithData:(NSData *)data forName:(NSString *)name fileName:(NSString *)fileName contentType:(NSString *)contentType;
- (void)addFileWithData:(NSData *)data forName:(NSString *)name contentType:(NSString *)contentType;

@end