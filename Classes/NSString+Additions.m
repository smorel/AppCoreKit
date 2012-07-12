//
//  NSString+Additions.m
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (CKNSStringAdditions)

+ (NSString*)stringWithNewUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}

- (NSString *)stringByTruncatingToLength:(NSUInteger)length withEllipsisString:(NSString *)ellipsis {
	if(self.length <= length) { return self; }
	NSMutableString *result = [NSMutableString stringWithString:self];
	[result insertString:ellipsis atIndex:length - [ellipsis length]];
	return [[[result substringToIndex:length] copy] autorelease];
}

- (NSString*)stringUsingASCIIEncoding {
	return [[[NSString alloc] initWithData:[self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding] autorelease];
}

@end
