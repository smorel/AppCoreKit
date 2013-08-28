//
//  NSData+Matching.m
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "NSData+Matching.h"

@implementation NSData (CKNSDataMatching)

// Knuth-Morris-Pratt Algorithm for Pattern Matching

- (NSUInteger)indexOfData:(NSData *)data searchRange:(NSRange)searchRange {
	if (self.length == 0) return NSNotFound;
	
	const UInt8 *buffer = [self bytes];
	const UInt8 *pattern = [data bytes];
	NSUInteger patternLength = data.length;
	
    // Computes the failure function using a boot-strapping process,
    // where the pattern is matched against itself.
	
	int failure[patternLength];
	memset(failure, 0, sizeof(int) * patternLength);
	
	int j = 0;
	for (int i = 1; i < patternLength; i++) {
		while (j > 0 && pattern[j] != pattern[i]) {
			j = failure[j - 1];
		}
		if (pattern[j] == pattern[i]) {
			j++;
		}
		failure[i] = j;
	}
	
	// Finds the first occurrence of the pattern in the sequence.
	
	j = 0;
	for (int i = searchRange.location; i < (searchRange.location + searchRange.length); i++) {
		while (j > 0 && pattern[j] != buffer[i]) {
			j = failure[j - 1];
		}
		if (pattern[j] == buffer[i]) { j++; }
		if (j == patternLength) {
			return i - patternLength + 1;
		}
	}
	return NSNotFound;
}

@end
