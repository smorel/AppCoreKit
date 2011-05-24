//
//  CKUIViewController+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController+Style.h"
#import "CKStyles.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"


@implementation CKUIViewController (CKStyle)

- (void)applyStyle{
	NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
	
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];
}

@end
