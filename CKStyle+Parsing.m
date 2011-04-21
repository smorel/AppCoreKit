//
//  CKStyle+Parsing.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyle+Parsing.h"

NSDictionary* CKEnumDictionaryFunc(NSString* strValues, ...) {
	NSMutableDictionary* dico = [NSMutableDictionary dictionary];
	NSArray* components = [strValues componentsSeparatedByString:@","];
	
	va_list ArgumentList;
	va_start(ArgumentList,strValues);
	
	int i = 0;
	while (i < [components count]){
		int value = va_arg(ArgumentList, int);
		[dico setObject:[NSNumber numberWithInt:value] forKey:[[components objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		++i;
    }
    va_end(ArgumentList);
	
	return dico;
}


@implementation CKStyleParsing

+ (NSInteger)parseString:(NSString*)str toEnum:(NSDictionary*)keyValues{
	return [[keyValues objectForKey:str]intValue];
}
			
+ (UIColor*)parseStringToColor:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 4,@"invalid color format");
	return [UIColor colorWithRed:[[components objectAtIndex:0]floatValue] 
						   green:[[components objectAtIndex:1]floatValue] 
							blue:[[components objectAtIndex:2]floatValue] 
						   alpha:[[components objectAtIndex:3]floatValue]];
}

+ (CGSize)parseStringToCGSize:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 2,@"invalid size format");
	return CGSizeMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}

@end
