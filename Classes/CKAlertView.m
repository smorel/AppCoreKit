//
//  CKAlertView.m
//  CloudKit
//
//  Created by Fred Brunel on 10-09-06.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKAlertView.h"

@implementation CKAlertView

@synthesize object = _object;

- (void)dealloc {
	self.object = nil;
	[super dealloc];
}

@end
