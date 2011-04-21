//
//  CKUIViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController.h"
#import "CKUIViewController+Style.h"


@implementation CKUIViewController
@synthesize name = _name;

- (void)dealloc{
	[_name release];
	[super dealloc];
}


-(void) viewDidLoad{
	[super viewDidLoad];
	[self applyStyle];
}

@end
