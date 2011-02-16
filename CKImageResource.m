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
		url = distantURL;
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	if(isWebUrlRegexString == nil){
		isWebUrlRegexString = @"^(http|https)$";
	}
	
	if(url && [[url scheme] isMatchedByRegex:isWebUrlRegexString]){
		UIImage* image = [CKImageLoader imageForURL:url];
		if(image){
			distantURL = url;
			NSString* imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[NSString stringWithNewUUID]]];
			NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
			[imageData writeToFile:imagePath atomically:YES];
			url = [NSURL URLWithString:imagePath];
		}
	}
	
	[super encodeWithCoder:aCoder];
	//Save images if we have http urls, modify the url and store http urls in temporary variables
}

//If 1 of the 2 urls are equal => the resource is considered as the same.
- (BOOL) isEqual:(id)other {
	if ([other isKindOfClass:[self class]]) {
		CKImageResource* otherResource = other;
		return ([self.url isEqual:otherResource.url] || [self.distantURL isEqual:otherResource.distantURL]
				|| [otherResource.url isEqual:self.url] || [otherResource.distantURL isEqual:self.distantURL]);
	}
	return NO;
}


@end

