//
//  CKWebRequest+Mapping.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebRequest.h"

/**
 */
@interface CKWebRequest (StandardRequests)

///-----------------------------------
/// @name Creating Initialized WebRequests
///-----------------------------------

/**
 */
+ (CKWebRequest*) requestForObjectsWithUrl:(NSURL*)url
                                    params:(NSDictionary*)params
                                      body:(NSData*)body
                  mappingContextIdentifier:(NSString*)mappingIdentifier
                          transformRawData:(NSArray*(^)(id value))transformRawDataBlock
                                completion:(void(^)(NSArray* objects))completionBlock 
                                     error:(void(^)(id value, NSHTTPURLResponse* response, NSError* error))errorBlock;

/**
 */
+ (CKWebRequest*)requestForObject:(id)object
                              url:(NSURL*)url
                           params:(NSDictionary*)params
                             body:(NSData*)body
         mappingContextIdentifier:(NSString*)identifier
                 transformRawData:(NSDictionary*(^)(id value))transformRawDataBlock
                       completion:(void(^)(id object))completionBlock 
                            error:(void(^)(id value, NSHTTPURLResponse* response, NSError* error))errorBlock;

@end
