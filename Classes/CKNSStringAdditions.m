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

- (NSString *)stringByTruncatingToLength:(NSUInteger)length withEllipsisString:(NSString *)ellipsis {
	if(self.length <= length) { return self; }
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	[result insertString:ellipsis atIndex:length - [ellipsis length]];
	return [[[result substringToIndex:length] copy] autorelease];
}

@end
