//
//  CKCompatibility.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCompatibility.h"
#import "CKVersion.h"


CGSize CKShadowSizeMake(CGFloat width, CGFloat height) {
	height = ([CKOSVersion() floatValue] < 3.2) ? -height : height;
	return CGSizeMake(width, height);
}