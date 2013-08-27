//
//  CKWebService.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKWebService.h"
#import "CKWebRequestManager.h"

static NSString * const CKUBWebServiceAlertTypeNetworkReachability = @"CKWebServiceAlertTypeNetworkReachability";

@interface CKWebService ()

@property (nonatomic, retain, readwrite) NSMutableDictionary *defaultParams;
@property (nonatomic, retain, readwrite) NSMutableDictionary *defaultHeaders;

@end

//

@implementation CKWebService {
	Reachability *_reachability;
	NSURL *_baseURL;
	NSMutableDictionary *_defaultParams;
	NSMutableDictionary *_defaultHeaders;
}

@synthesize baseURL = _baseURL;
@synthesize defaultParams = _defaultParams;
@synthesize defaultHeaders = _defaultHeaders;

static NSMutableDictionary* CKWebServiceSharedInstances = nil;
#pragma mark Initialization

+ (id)sharedWebService {
	static id CKWebServiceSharedInstances = nil;
    
    id sharedService = nil;
	if (CKWebServiceSharedInstances == nil) {
        CKWebServiceSharedInstances = [[NSMutableDictionary alloc]init];
	}
    sharedService = [CKWebServiceSharedInstances objectForKey:[[self class]description]];
    if(sharedService == nil){
        sharedService = [[[[self class] alloc] init]autorelease];
        [CKWebServiceSharedInstances setObject:sharedService forKey:[[self class]description]];    
    }
	return sharedService;
}

+ (void)setSharedWebService:(id)sharedWebService {
    [CKWebServiceSharedInstances setObject:sharedWebService forKey:[[self class]description]];    
}

//

- (id)init {
	if (self = [super init]) {
		self.defaultParams = [NSMutableDictionary dictionary];
		self.defaultHeaders = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)dealloc {
	self.baseURL = nil;
	self.defaultParams = nil;
	self.defaultHeaders = nil;
	[super dealloc];
}

#pragma mark Create Requests

- (id)performRequest:(CKWebRequest *)request {
    [[CKWebRequestManager sharedManager] scheduleRequest:request];
	return request;
}

#pragma mark Request Facade

- (CKWebRequest*)requestForPath:(NSString *)path params:(NSDictionary *)params {
	NSString *theURL = self.baseURL ? [[self.baseURL absoluteString] stringByAppendingString:path] : path;
	
	NSDictionary *theParams = nil;
	if (self.defaultParams && [self.defaultParams count] > 0) {
		NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.defaultParams];
		[dic addEntriesFromDictionary:params];
		theParams = dic;
	} else {
		theParams = params;
	}
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:theURL]];
    [self.defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
	
    return [[[CKWebRequest alloc] initWithURLRequest:request parameters:theParams completion:nil] autorelease];
}

@end