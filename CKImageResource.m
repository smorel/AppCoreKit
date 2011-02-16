//
//  CKImageResource.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKImageResource.h"
#import "CKImageLoader.h"
#import "CKNSStringAdditions.h"
#import <CloudKit/RegexKitLite.h>

@interface CKImageResource ()
@property (nonatomic, retain) NSURL *distantURL;
@end

static NSString* isWebUrlRegexString = nil;
@implementation CKImageResource

@synthesize url;
@synthesize distantURL;

- (id) initWithCoder:(NSCoder *)aDecoder {
	[super initWithCoder:aDecoder];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:[url absoluteString]] ){
		self.url = self.distantURL;
	}
	
	return self;
}

- (BOOL)isDistantUrl:(NSURL*)theUrl{
	if(isWebUrlRegexString == nil){
		isWebUrlRegexString = @"^(http|https)$";
	}
	
	if(theUrl && [[theUrl scheme] isMatchedByRegex:isWebUrlRegexString])
		return YES;
	return NO;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	if([self isDistantUrl:url]){
		UIImage* image = [CKImageLoader imageForURL:url];
		if(image){
			self.distantURL = url;
			NSString* imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[NSString stringWithNewUUID]]];
			NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
			[imageData writeToFile:imagePath atomically:YES];
			self.url = [NSURL URLWithString:imagePath];
		}
	}
	
	[super encodeWithCoder:aCoder];
}

- (void)setUrl:(NSURL *)theUrl{
	[url release];
	url = [theUrl retain];
	
	if([self isDistantUrl:url]){
		self.distantURL = url;
	}
}

- (void)urlMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.comparable = NO;
	metaData.hashable = NO;
}

@end

