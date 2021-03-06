//
//  CKVersion.m
//  AppCoreKit
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
    
    Class ARServiceClass = NSClassFromString(@"ARService");
	NSString *appVersion = [NSString stringWithFormat:((ARServiceClass != nil) ? @"%@ [%@]" : @"%@ (%@)"), versionNumber, buildNumber];
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