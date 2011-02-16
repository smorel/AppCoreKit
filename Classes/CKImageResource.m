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

@implementation CKImageResource

- (void) encodeWithCoder:(NSCoder *)aCoder {
	if([self isRemoteUrl:url]){
		UIImage* image = [CKImageLoader imageForURL:url];
		if(image){
			self.remoteURL = url;
			NSString* imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[NSString stringWithNewUUID]]];
			NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
			[imageData writeToFile:imagePath atomically:YES];
			self.url = [NSURL URLWithString:imagePath];
		}
	}
	
	[super encodeWithCoder:aCoder];
}

@end

