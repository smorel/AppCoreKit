//
//  CKMultipartParser.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

//  Parse a MIME multipart message (eg. form-data), but 
//  does not parse the individual chunks more than necessary.
//
//  BOOL nextChunk = [parser skipPreamble];
//  while (nextChunk) {
//	  NSData *headerChunk = [parser readHeadersData];
//	  NSData *bodyChunk = [parser readBodyData];
//	  nextChunk = [parser readBoundary];
//  }

#import <Foundation/Foundation.h>


/** TODO
 */
@interface CKMultipartParser : NSObject {
	NSData *buffer;
	NSData *headerSeparator;
	NSData *fieldSeparator;
	NSData *streamTerminator;
	NSData *boundarySeparator;
	NSUInteger head;
}

- (id)initWithData:(NSData *)data boundary:(NSString *)boundary;

- (BOOL)skipPreamble;
- (BOOL)readBoundary;
- (NSData *)readHeadersData;
- (NSDictionary *)readHeaders;
- (NSData *)readBodyData;

@end
