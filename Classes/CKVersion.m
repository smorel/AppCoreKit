//
//  CKVersion.m
//  LOLEWall
//
//  Created by Fred Brunel on 10-08-09.
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
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        osVersion = [[[UIDevice currentDevice] systemVersion]retain];
    });
	return osVersion;
}