//
//  NSString+Parsing.m
//  CloudKit
//
//  Created by Jean-Philippe Martin on 11-02-04.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSString+Parsing.h"


@implementation NSString (Parsing)

- (NSString *)stringByDeletingHTMLTags {
	
	NSString *parsedText = [[self copy] autorelease];
	NSScanner *s = [NSScanner scannerWithString:parsedText];
	
	while (![s isAtEnd]) {
		
		NSString *text = @"";
		[s scanUpToString:@"<" intoString:NULL];
		[s scanUpToString:@">" intoString:&text];
		
		parsedText = [parsedText stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
	}
	
	return parsedText;
}

@end
