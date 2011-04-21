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


@implementation CKUIViewController (CKStyle)

- (void)applyStyle{
	NSDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:self  propertyName:@""];
	
	NSMutableSet* appliedStack = [NSMutableSet set];
	[[self.view class] applyStyle:controllerStyle toView:self.view propertyName:@"view" appliedStack:appliedStack];
	[self.view applySubViewsStyle:controllerStyle appliedStack:appliedStack];
}

@end
