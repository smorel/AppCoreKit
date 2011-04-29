//
//  CKStyle+Parsing.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyle+Parsing.h"
#import "CKUIColorAdditions.h"

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
	if([components count] == 4){
		return [UIColor colorWithRed:[[components objectAtIndex:0]floatValue] 
						   green:[[components objectAtIndex:1]floatValue] 
							blue:[[components objectAtIndex:2]floatValue] 
						   alpha:[[components objectAtIndex:3]floatValue]];
	}
	else {
		if([str hasPrefix:@"0x"]){
			NSArray* components = [str componentsSeparatedByString:@" "];
			NSAssert([components count] >= 1,@"Invalid format for color");
			unsigned outVal;
			NSScanner* scanner = [NSScanner scannerWithString:[components objectAtIndex:0]];
			[scanner scanHexInt:&outVal];
			UIColor* color = [UIColor colorWithRGBValue:outVal];
			
			if([components count] > 1){
				color = [color colorWithAlphaComponent:[[components objectAtIndex:1] floatValue] ];
			}
			return color;
		}
		else{
			NSAssert(NO,@"Invalid format for color");
		}
	}

	return nil;
}

+ (CGSize)parseStringToCGSize:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 2,@"invalid size format");
	return CGSizeMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}

@end


//TODO : HERE store the converted data in the key to convert only once !

@implementation NSMutableDictionary (CKStyleParsing)

- (UIColor*) colorForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSString class]]){
		UIColor* result = [CKStyleParsing parseStringToColor:[object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		[self setObject:result forKey:key];
		return result;
	}
	else if([object isKindOfClass:[NSNumber class]]){
		UIColor* result = [UIColor colorWithRGBValue:[object intValue]];
		[self setObject:result forKey:key];
		return result;
	}
	NSAssert(object == nil || [object isKindOfClass:[UIColor class]],@"invalid class for color");
	return (object == nil) ? [UIColor whiteColor] : (UIColor*)object;
}

- (NSArray*) colorArrayForKey:(NSString*)key{
	id object = [self objectForKey:key];
	NSAssert(object == nil || [object isKindOfClass:[NSArray class]],@"invalid class for color array");
	NSMutableArray* values = [NSMutableArray array];
	BOOL converted = NO;
	for(id value in object){
		if([value isKindOfClass:[NSString class]]){
			[values addObject:[CKStyleParsing parseStringToColor:value]];
			converted = YES;
		}
		else{
			NSAssert([value isKindOfClass:[UIColor class]],@"invalid class for color array");
			[values addObject:value];
		}
	}
	if(converted){
		[self setObject:values forKey:key];
	}
	return values;
}

- (NSArray*) cgFloatArrayForKey:(NSString*)key{
	id object = [self objectForKey:key];
	NSAssert(object == nil || [object isKindOfClass:[NSArray class]],@"invalid class for float array");
	NSMutableArray* values = [NSMutableArray array];
	BOOL converted = NO;
	for(id value in object){
		if([value isKindOfClass:[NSString class]]){
			[values addObject:[NSNumber numberWithFloat:[value floatValue]]];
			converted = YES;
		}
		else{
			NSAssert([value isKindOfClass:[NSNumber class]],@"invalid class for color float array");
			[values addObject:value];
		}
	}if(converted){
		[self setObject:values forKey:key];
	}
	return values;
}

- (UIImage*) imageForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSString class]]){
		UIImage* image = [UIImage imageNamed:object];
		if(image != nil){
			[self setObject:image forKey:key];
		}
		return image;
	}
	else if([object isKindOfClass:[NSURL class]]){
		NSURL* url = (NSURL*)object;
		if([url isFileURL]){
			UIImage* image = [UIImage imageWithContentsOfFile:[url path]];
			if(image != nil){
				[self setObject:image forKey:key];
			}
			return image;
		}
		NSAssert(NO,@"Styles only supports file url yet");
		return nil;
	}
	
	NSAssert(object == nil || [object isKindOfClass:[UIImage class]],@"invalid class for image");
	return (UIImage*)object;	
}

- (NSInteger) enumValueForKey:(NSString*)key withDictionary:(NSDictionary*)dictionary{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSString class]]){
		NSInteger result = [CKStyleParsing parseString:object toEnum:dictionary];
		[self setObject:[NSNumber numberWithInt:result] forKey:key];
		return result;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for enum");
	return (object == nil) ? 0 : [object intValue];
}

- (CGSize) cgSizeForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSString class]]){
		CGSize size = [CKStyleParsing parseStringToCGSize:object];
		[self setObject:[NSValue valueWithCGSize:size] forKey:key];
		return size;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGSizeMake(10,10) : [object CGSizeValue];
}

- (CGFloat) cgFloatForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSString class]]){
		CGFloat result = [object floatValue];
		[self setObject:[NSNumber numberWithFloat:result] forKey:key];
		return result;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for cgfloat");
	return (object == nil) ? 11 : [object floatValue];
}


- (NSString*) stringForKey:(NSString*)key{
	id object = [self objectForKey:key];
	NSAssert(object == nil || [object isKindOfClass:[NSString class]],@"invalid class for string");
	return (NSString*)object;
}

- (NSInteger) integerForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if([object isKindOfClass:[NSString class]]){
		NSInteger result = [object intValue];
		[self setObject:[NSNumber numberWithInt:result] forKey:key];
		return result;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for integer");
	return (object == nil) ? 0 : [object intValue];
}

@end