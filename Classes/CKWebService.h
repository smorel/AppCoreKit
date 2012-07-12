//
//  CKWebService.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKWebRequest.h"

@class Reachability;


/**
 */
@interface CKWebService : NSObject

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (id)sharedWebService;

/**
 */
+ (void)setSharedWebService:(id)sharedWebService;

///-----------------------------------
/// @name Configuring WebService
///-----------------------------------

/**
 */
@property (nonatomic, retain, readwrite) NSURL *baseURL;

/**
 */
@property (nonatomic, retain, readonly) NSMutableDictionary *defaultParams;

/**
 */
@property (nonatomic, retain, readonly) NSMutableDictionary *defaultHeaders;


///-----------------------------------
/// @name Creating an initialized Web Request
///-----------------------------------

/**
 */
- (CKWebRequest*)requestForPath:(NSString *)path params:(NSDictionary *)params;

///-----------------------------------
/// @name Executing a managed Web Request
///-----------------------------------

/**
 */
- (id)performRequest:(CKWebRequest *)request;


@end
