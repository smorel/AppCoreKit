//
//  CKInetEndPoint.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKInetEndPoint.h"

@implementation CKInetEndPoint{
	NSString *_inetAddressRepresentation;
	NSUInteger _port;
}

@synthesize inetAddressRepresentation = _inetAddressRepresentation;
@synthesize port = _port;

- (id)initWithCSockAddr:(const struct sockaddr_in *)addr {
	if (self = [super init]) {
		_inetAddressRepresentation = [[NSString alloc] initWithCString:(const char *)inet_ntoa(addr->sin_addr) encoding:NSASCIIStringEncoding];
		_port = ntohs(addr->sin_port);
	}
	return self;
}

- (void)dealloc {
	[_inetAddressRepresentation release];
	[super dealloc];
}

//

- (NSString *)description {
	return [NSString stringWithFormat:@"%@:%d", self.inetAddressRepresentation, self.port];
}

@end
