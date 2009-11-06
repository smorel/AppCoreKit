//
//  CKNSArrayAdditions.m
//
//  Created by Fred Brunel on 05/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSArrayAdditions.h"

@implementation NSArray (CKNSArrayAdditions)

- (id)first {
	return [self objectAtIndex:0];
}

- (id)second {
	return [self objectAtIndex:1];
}

- (id)last {
	return [self lastObject];
}

- (NSArray *)rest {
	if (self.count == 0) return self;
	NSRange range;
	range.location = 1;
	range.length = self.count - 1;
	return [self subarrayWithRange:range];
}

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

- (BOOL)containsString:(NSString *)string {
	for (NSObject *object in self) {
		if ([object isKindOfClass:[NSString class]]) {
			if ([(NSString *)object isEqualToString:string]) { return YES; }
		}
	}
	return NO;
}

- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate {
	for (NSObject *object in self) {
		if ([predicate evaluateWithObject:object] == TRUE) { return YES; }
	}
	return NO;
}

- (NSArray *)arrayByApplyingSelector:(SEL)selector {
	NSMutableArray *array = [NSMutableArray array];
	for (NSObject *object in self) {
		if ([object respondsToSelector:selector]) {
			[array addObject:[object performSelector:selector]];
		}
	}
	return array;
}

@end

//

@implementation NSSet (CKNSSetAdditions)

- (BOOL)containsObjectWithPredicate:(NSPredicate *)predicate {
	for (NSObject *object in self) {
		if ([predicate evaluateWithObject:object] == TRUE) { return YES; }
	}
	return NO;
}

@end
