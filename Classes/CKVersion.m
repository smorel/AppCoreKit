//
//  CKVersion.m
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKVersion.h"

NSString *CKApplicationVersion() {
	NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];		
	NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)", versionNumber, buildNumber];
	return appVersion;
}

static NSString* osVersion = nil;
NSString *CKOSVersion() {
	if(osVersion == nil){
		osVersion = [[[UIDevice currentDevice] systemVersion]retain];
	}
	return osVersion;
}