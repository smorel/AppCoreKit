//
//  CKNSDictionary+Styles.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyles.h"
#import "CKStyleManager.h"

#import "CKNSObject+Introspection.h"
#import <objc/runtime.h>

#import "CKValueTransformer.h"

static NSDictionary* CKStyleDefaultDictionary = nil;

@implementation CKStyleFormat
@synthesize objectClass,properties,format,propertyName;

- (id)initFormatWithFormat:(NSString*)theformat{
	[super init];
	self.format = theformat;
	self.properties = [NSMutableArray array];
	NSArray* components = [theformat componentsSeparatedByString:@","];
	NSAssert([components count] > 0,@"invalid format : missing type");
	
	NSString* identifier = (NSString*)[components objectAtIndex:0];
	if([identifier hasPrefix:@"#"]){
		self.propertyName = [identifier substringWithRange:NSMakeRange(1,[identifier length] - 1)];
	}
	else{
		self.objectClass = NSClassFromString(identifier);
	}
	
	for(int i=1;i<[components count];++i){
		NSString* propertyValueString = [components objectAtIndex:i];
		NSArray* components2 = [propertyValueString componentsSeparatedByString:@"="];
		NSAssert([components2 count] == 2,@"invalid format for property");
		[self.properties addObject:[components2 objectAtIndex:0]];
	}
	return self;
}

- (NSString*)formatForObject:(id)object propertyName:(NSString*)thePropertyName{
	NSString* str = nil;
	if(self.propertyName){
		str = [NSString stringWithFormat:@"#%@",thePropertyName];
	}
	else{
		NSString* classname = [object className];
		classname = [classname stringByReplacingOccurrencesOfString:@"_MAZeroingWeakRefSubclass" withString:@""];
		str = [NSString stringWithFormat:@"%@",classname];
	}
	
	for(NSString* subPropertyName in properties){
		id value = [object valueForKeyPath:subPropertyName];
		NSString* valueString = [CKValueTransformer transformValue:value toClass:[NSString class]];
		str = [str stringByAppendingFormat:@",%@=%@",subPropertyName,valueString];
	}
	return str;
}

@end


@implementation NSDictionary (CKKey)

- (BOOL)containsObjectForKey:(NSString*)key{
	id object = [self objectForKey:key];
	return (object != nil);
}

@end

NSString* CKStyleFormats = @"formats";

@implementation NSMutableDictionary (CKStyle)

- (void)setFormat:(CKStyleFormat*)format{
	NSMutableDictionary* formats = [self objectForKey:CKStyleFormats];
	if(!formats){
		formats = [NSMutableDictionary dictionary];
		[self setObject:formats forKey:CKStyleFormats];
	}
	
	id formatKey = (format.objectClass != nil) ? (id)format.objectClass : (id)format.propertyName;
	NSMutableArray* formatsForClass = [formats objectForKey:formatKey];
	if(!formatsForClass){
		formatsForClass = [NSMutableArray array];
		[formats setObject:formatsForClass forKey:formatKey];
	}
	
	//order format the most specialized at the beginning
	NSInteger propertiesCount = [format.properties count];
	BOOL inserted = NO;
	for(int i=0;i<[formatsForClass count];++i){
		CKStyleFormat* other = [formatsForClass objectAtIndex:i];
		if(propertiesCount > [other.properties count]){
			[formatsForClass insertObject:format atIndex:i];
			inserted = YES;
			break;
		}
	}
	
	if(inserted == NO){
		[formatsForClass addObject:format];
	}
}

- (void)setStyle:(NSDictionary*)style forKey:(NSString*)key{
	[self setObject:style forKey:key];

	CKStyleFormat* format = [[[CKStyleFormat alloc]initFormatWithFormat:key]autorelease];
	[self setFormat:format];
}


- (void)initAfterLoading{
	for(id key in [self allKeys]){
		id object = [self objectForKey:key];
		if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKStyleFormats] == NO){
			NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:object];
			[self setObject:dico forKey:key];
			
			CKStyleFormat* format = [[[CKStyleFormat alloc]initFormatWithFormat:key]autorelease];
			[self setFormat:format];
			[dico initAfterLoading];
		}
	}
	//iterate on styles key and create formats
	//call initAfterLoading on subStyles
}

@end

@implementation NSDictionary (CKStyle)

- (NSDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
	NSArray* formatsForObject = [self styleFormatsForObject:object propertyName:propertyName];
	if(formatsForObject){
		for(CKStyleFormat* format in formatsForObject){
			NSString* objectFormatKey = [format formatForObject:object propertyName:propertyName];
			id style = [self objectForKey:objectFormatKey];
			if(style){
				return style;
			}
		}
	}
	
	NSDictionary* managerStyles = [CKStyleManager defaultManager].styles;
	if(managerStyles == self){
		if(CKStyleDefaultDictionary == nil){
			CKStyleDefaultDictionary = [NSDictionary dictionary];
		}
		return CKStyleDefaultDictionary;
	}
	//if not found, search in the root style directory
	return [managerStyles styleForObject:object propertyName:propertyName];
}

- (NSArray*)styleFormatsForObject:(id)object propertyName:(NSString*)propertyName{
	NSMutableArray* resultFormats = [NSMutableArray array];
	NSDictionary* allFormats = [self objectForKey:CKStyleFormats];
	if(allFormats){
		NSArray* propertyformats = [allFormats objectForKey:propertyName];
		if(propertyformats){
			[resultFormats addObjectsFromArray:propertyformats];
		}
		
		Class type = [object class];
		while(type != nil){
			NSArray* formats = [allFormats objectForKey:type];
			if(formats){
				[resultFormats addObjectsFromArray:formats];
				break;
			}
			type = class_getSuperclass(type);
		}
	}
	return resultFormats;
}

@end
