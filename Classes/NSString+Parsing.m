//
//  NSString+Parsing.m
//  AppCoreKit
//
//  Created by Jean-Philippe Martin.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "NSString+Parsing.h"


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


- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet*)set{
    NSMutableString* str = [NSMutableString string];
    for(int i =0;i<[self length];++i){
        unichar c = [self characterAtIndex:i]; 
        if(![set characterIsMember:c]){
            [str appendFormat:@"%c",c];
        }
    }
    return str;
}

@end
