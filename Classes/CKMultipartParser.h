//
//  CKMultipartParser.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//



#import <Foundation/Foundation.h>


/**  Parse a MIME multipart message (eg. form-data), but 
   does not parse the individual chunks more than necessary.
 
       BOOL nextChunk = [parser skipPreamble];
       while (nextChunk) {
 	      NSData *headerChunk = [parser readHeadersData];
 	      NSData *bodyChunk = [parser readBodyData];
 	      nextChunk = [parser readBoundary];
       }
 */
@interface CKMultipartParser : NSObject 

///-----------------------------------
/// @name Creating Multipart Parser Objects
///-----------------------------------

/**
 */
- (id)initWithData:(NSData *)data boundary:(NSString *)boundary;

///-----------------------------------
/// @name Accessing Multipart Parsed Content
///-----------------------------------

/**
 */
- (BOOL)skipPreamble;

/**
 */
- (BOOL)readBoundary;

/**
 */
- (NSData *)readHeadersData;

/**
 */
- (NSDictionary *)readHeaders;

/**
 */
- (NSData *)readBodyData;

@end
