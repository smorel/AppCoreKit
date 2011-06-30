//
//  CKBonjourResolver.m
//  CloudKit
//
//  Created by Fred Brunel on 10-12-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKBonjourResolver.h"
#import "CKInetEndPoint.h"

#import "CKNSString+Validations.h"
#import "CKDebug.h"

@interface CKBonjourResolver ()
@property (nonatomic, copy) NSString *nameRegex;
@end

//

@implementation CKBonjourResolver

@synthesize delegate = _delegate;
@synthesize nameRegex = _nameRegex;

- (id)init {
	if (self = [super init]) {
		_netServiceBrowser = [[NSNetServiceBrowser alloc] init];
		_netServiceBrowser.delegate = self;
		_unresolvedServices = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)dealloc {
	_delegate = nil;
	[_netServiceBrowser release];
	[_unresolvedServices release];
	[_nameRegex release];
	[super dealloc];
}

//

- (void)searchForServicesOfType:(NSString *)serviceType inDomain:(NSString *)domainName {
	[self searchForServicesOfType:serviceType inDomain:domainName withNameMatchingRegex:nil];
}

- (void)searchForServicesOfType:(NSString *)serviceType inDomain:(NSString *)domainName withNameMatchingRegex:(NSString *)regex {
	if (_searching == NO) {
		self.nameRegex = regex;
		[_netServiceBrowser searchForServicesOfType:serviceType inDomain:domainName];
	}
}

- (void)stop {
	[_netServiceBrowser stop];
	[_unresolvedServices removeAllObjects];
}

#pragma mark NSNetServiceBrowserDelegate Protocol

- (void)netServiceBrowser:(NSNetServiceBrowser *)theNetServiceBrowser didFindService:(NSNetService *)theNetService moreComing:(BOOL)more {
	if (self.nameRegex && ([theNetService.name isValidFormat:self.nameRegex] == NO))
		return;
	
	[_unresolvedServices addObject:theNetService];
	[theNetService setDelegate:self];
	[theNetService resolveWithTimeout:5.0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)theNetServiceBrowser didRemoveService:(NSNetService *)theNetService moreComing:(BOOL)more {
	if (self.nameRegex && ([theNetService.name isValidFormat:self.nameRegex] == NO))
		return;
	
	[self.delegate bonjourResolver:self didRemoveServiceNamed:theNetService.name];
	[_unresolvedServices removeObject:theNetService];
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)theNetServiceBrowser {
    _searching = YES;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)theNetServiceBrowser {
    _searching = NO;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict {
	_searching = NO;
}

#pragma mark NSNetServiceDelegate Protocol

- (void)netServiceDidResolveAddress:(NSNetService *)theNetService {
	NSMutableArray *inetEndPoints = [NSMutableArray array];

	for (NSData *address in theNetService.addresses) {
		struct sockaddr_in *addr = (struct sockaddr_in *)[address bytes];
		
		// Make sure we only use an IPv4 address family. An IPv6 address will be parsed in "0.0.0.0"
		// Ref. http://developer.apple.com/library/mac/#qa/qa2001/qa1298.html
		
		if (addr->sin_family == AF_INET) {
			CKInetEndPoint *inetEndPoint = [[[CKInetEndPoint alloc] initWithCSockAddr:addr] autorelease];
			[inetEndPoints addObject:inetEndPoint];
		}
	}
	
	[self.delegate bonjourResolver:self didResolveServiceNamed:theNetService.name hostName:theNetService.hostName inetEndPoints:inetEndPoints];
	[_unresolvedServices removeObject:theNetService];
}

- (void)netService:(NSNetService *)theNetService didNotResolve:(NSDictionary *)errorDict {
	[_unresolvedServices removeObject:theNetService];
}
	
@end