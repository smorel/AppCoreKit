//
//  CKInetEndPoint.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//
//  Represents a network endpoint as an IP address and a port number.

#import <Foundation/Foundation.h>

#import <netinet/in.h>
#import <arpa/inet.h>


/**
 */
@interface CKInetEndPoint : NSObject 

///-----------------------------------
/// @name Initializing an InetEndPoint Object
///-----------------------------------

/**
 */
- (id)initWithCSockAddr:(const struct sockaddr_in *)addr;


///-----------------------------------
/// @name Accessing an InetEndPoint Attributes
///-----------------------------------

/**
 */
@property (nonatomic, readonly) NSString *inetAddressRepresentation;

/**
 */
@property (nonatomic, readonly) NSUInteger port;


@end
