//
//  CKNSStringAdditions.m
//
//  Created by Fred Brunel on 04/08/2007.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKNSStringAdditions.h"

@implementation NSString (CKNSStringAdditions)

+ (NSString*)stringWithNewUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}

// Validate if a string is valid as an email address
// which can potentially be empty as well.
- (BOOL) stringIsValidAsEmail:(BOOL)allowEmptyString {
	// Validate email
	if ([self length] == 0) {
		if (allowEmptyString) return YES;
		return NO;
	}
	NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
	NSPredicate *regextest = [NSPredicate
							  predicateWithFormat:@"SELF MATCHES %@", regex];
	if ([regextest evaluateWithObject:self] == NO) {
		return NO;
	}	
	
	return YES;
}

- (NSString *)stringTruncatedToLength:(NSUInteger)length withEllipsisString:(NSString *)ellipsis {
	if(self.length <= length) { return self; }
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	[result insertString:ellipsis atIndex:length - [ellipsis length]];
	return [[[result substringToIndex:length] copy] autorelease];
}

@end
