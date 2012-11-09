//
//  CKBonjourResolver.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKBonjourResolver;

/**
 */
@protocol CKBonjourResolverDelegate

///-----------------------------------
/// @name Customizing the Bonjour Resolver Behaviour
///-----------------------------------

/**
 */
- (void)bonjourResolver:(CKBonjourResolver *)bonjourResolver didResolveServiceNamed:(NSString *)name hostName:(NSString *)hostName inetEndPoints:(NSArray *)inetEndPoints;

/**
 */
- (void)bonjourResolver:(CKBonjourResolver *)bonjourResolver didRemoveServiceNamed:(NSString *)name;

@end

//

/**
 */
@interface CKBonjourResolver : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate> 

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property (nonatomic, assign) id<CKBonjourResolverDelegate> delegate;


///-----------------------------------
/// @name Querying the Bonjour Resolver
///-----------------------------------

/**
 */
- (void)searchForServicesOfType:(NSString *)serviceType inDomain:(NSString *)domainName;


/**
 */
- (void)searchForServicesOfType:(NSString *)serviceType inDomain:(NSString *)domainName withNameMatchingRegex:(NSString *)regex;


///-----------------------------------
/// @name Cancelling the Bonjour Resolver
///-----------------------------------

/**
 */
- (void)cancel;

@end