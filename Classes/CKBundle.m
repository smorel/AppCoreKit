//
//  CKBundle.m
//  CloudKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBundle.h"

static NSString * const CKBundleName = @"CloudKit.bundle";

@implementation CKBundle

+ (UIImage *)imageForName:(NSString *)name {
	return [UIImage imageNamed:name];
//	NSString *path = [CKBundleName stringByAppendingPathComponent:[NSString stringWithFormat:@"Images/%@", name]];
//	return [UIImage imageNamed:path];
}

@end
