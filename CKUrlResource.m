//
//  CKUrlResource.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUrlResource.h"
#import <CloudKit/RegexKitLite.h>

static NSString* isWebUrlRegexString = nil;
@implementation CKUrlResource

@synthesize url;
@synthesize remoteURL;

- (id) initWithCoder:(NSCoder *)aDecoder {
	[super initWithCoder:aDecoder];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:[url absoluteString]] ){
		self.url = self.remoteURL;
	}
	
	return self;
}

- (BOOL)isRemoteUrl:(NSURL*)theUrl{
	if(isWebUrlRegexString == nil){
		isWebUrlRegexString = @"^(http|https)$";
	}
	
	if(theUrl && [[theUrl scheme] isMatchedByRegex:isWebUrlRegexString])
		return YES;
	return NO;
}

- (void)setUrl:(NSURL *)theUrl{
	[url release];
	url = [theUrl retain];
	
	if([self isRemoteUrl:url]){
		self.remoteURL = url;
	}
}

- (void)urlMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.comparable = NO;
	metaData.hashable = NO;
}

@end
