//
//  CKWebRequest+Initialization.h
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebRequest.h"

/**
 */
@interface CKWebRequest (Initialization)

///-----------------------------------
/// @name Creating WebRequest Objects
///-----------------------------------

/**
 */
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters;

/**
 */
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
+(CKWebRequest*)scheduledRequestWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;


///-----------------------------------
/// @name Initializing WebRequest Objects
///-----------------------------------

/**
 */
- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters;

/**
 */
- (id)initWithURL:(NSURL*)url completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
- (id)initWithURL:(NSURL*)url transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
- (id)initWithURL:(NSURL*)url parameters:(NSDictionary*)parameters downloadAtPath:(NSString*)path completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
- (id)initWithURLRequest:(NSURLRequest*)request completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
- (id)initWithURLRequest:(NSURLRequest*)request transform:(id (^)(id value))transform completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

/**
 */
- (id)initWithURLRequest:(NSURLRequest*)request parameters:(NSDictionary*)parameters completion:(void (^)(id object, NSHTTPURLResponse *response, NSError *error))block;

@end
