//
//  CKNSSetAdditions.m
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSSetAdditions.h"

@implementation NSSet (CKNSSetAdditions)

- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate {
	for (NSObject *object in self) {
		if ([predicate evaluateWithObject:object] == TRUE) { return YES; }
	}
	return NO;
}

@end