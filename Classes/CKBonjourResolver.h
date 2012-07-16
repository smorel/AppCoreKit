//
//  CKBonjourResolver.h
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKBonjourResolver;

/** TODO
 */
@protocol CKBonjourResolverDelegate

- (void)bonjourResolver:(CKBonjourResolver *)bonjourResolver didResolveServiceNamed:(NSString *)name hostName:(NSString *)hostName inetEndPoints:(NSArray *)inetEndPoints;
- (void)bonjourResolver:(CKBonjourResolver *)bonjourResolver didRemoveServiceNamed:(NSString *)name;

@end

//

/** TODO
 */
@interface CKBonjourResolver : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
	NSNetServiceBrowser *_netServiceBrowser;
	NSMutableArray *_unresolvedServices;
	id<CKBonjourResolverDelegate> _delegate;
	BOOL _searching;
	NSString *_nameRegex;
}

@property (nonatomic, assign) id<CKBonjourResolverDelegate> delegate;

- (void)searchForServicesOfType:(NSString *)serviceType inDomain:(NSString *)domainName;
- (void)searchForServicesOfType:(NSString *)serviceType inDomain:(NSString *)domainName withNameMatchingRegex:(NSString *)regex;
- (void)stop;

@end