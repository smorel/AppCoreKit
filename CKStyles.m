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

#import "RegexKitLite.h"
#import "CKObjectProperty.h"
#import "CKNSValueTransformer+Additions.h"

static NSMutableDictionary* CKStyleClassNamesCache = nil;

@implementation CKStyleFormat
@synthesize objectClass,properties,format,propertyName;

- (void)dealloc{
	[format release];
	[propertyName release];
	[properties release];
	[super dealloc];
}

+ (NSArray*)parseFormat:(NSString*)format{
	NSMutableArray* components = [NSMutableArray array];
	
	NSRange range1 = [format rangeOfString:@"["];
	if(range1.length > 0){//found "["
		NSString* identifier = [format substringWithRange:NSMakeRange(0,range1.location)];
		[components addObject:[identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		
		NSRange range2 = [format rangeOfString:@"]"];
		if(range2.length > 0){//found "]"
			NSString* allPropertyValuePairs = [format substringWithRange:NSMakeRange(range1.location +1,range2.location - range1.location - 1)];
			NSArray* propertyValuePairComponents = [allPropertyValuePairs componentsSeparatedByString:@";"];
			for(NSString* propetyValuePair in propertyValuePairComponents){
				NSArray* propertyValueComponents = [propetyValuePair componentsSeparatedByString:@"="];
				NSAssert([propertyValueComponents count] == 2,@"Invalid format for '%@' : invalid property value pair '%@'",format,propetyValuePair);
				
				NSString* propertyName = [propertyValueComponents objectAtIndex:0];
				propertyName = [propertyName stringByReplacingOccurrencesOfString:@"'" withString:@""];
				NSString* propertyValue = [propertyValueComponents objectAtIndex:1];
				propertyValue = [propertyValue stringByReplacingOccurrencesOfString:@"'" withString:@""];
				[components addObject:[propertyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
				[components addObject:[propertyValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
			}
		}
		else{
			NSLog(@"Invalid format for '%@' : Cannot find end selector character ']'",format);
		}
	}
	else{//no selectors
		[components addObject:[format stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	
	return components;
}

+ (NSString*)formatFromSplittedFormat:(NSArray*)splittedFormat{
	NSAssert([splittedFormat count] >= 1,@"no identifier for format");
	NSMutableString* str = [NSMutableString stringWithCapacity:1024];
	[str appendString:[splittedFormat objectAtIndex:0]];
	
	if([splittedFormat count] > 1){
		[str appendString:@"["];
	}
	
	for(int i=1;i<[splittedFormat count];i += 2){
		NSString* propertyName = [splittedFormat objectAtIndex:i];
		NSString* propertyValue = [splittedFormat objectAtIndex:i+1];
		[str appendFormat:@"%@%@='%@'",(i >= 3) ? @";" : @"" ,propertyName,propertyValue];
	}
	
	if([splittedFormat count] > 1){
		[str appendString:@"]"];
	}
	
	return str;
}

+ (NSString*)normalizeFormat:(NSString*)format{
	NSArray* splittedFormat = [CKStyleFormat parseFormat:format];
	return [CKStyleFormat formatFromSplittedFormat:splittedFormat];
}

- (id)initFormatWithFormat:(NSString*)theformat{
	[super init];
	self.properties = [NSMutableArray array];
	
	NSArray* splittedFormat = [CKStyleFormat parseFormat:theformat];
	self.format = [CKStyleFormat formatFromSplittedFormat:splittedFormat];
	
	NSString* identifier = (NSString*)[splittedFormat objectAtIndex:0];
	Class type = NSClassFromString(identifier);
	if(type == nil){
		self.propertyName = identifier;
	}
	else{
		self.objectClass = type;
	}
	
	for(int i=1;i<[splittedFormat count];i += 2){
		NSString* name = [splittedFormat objectAtIndex:i];
		//NSString* value = [splittedFormat objectAtIndex:i+1];
		[self.properties addObject:name];
	}
	return self;
}

- (NSString*)formatForObject:(id)object propertyName:(NSString*)thePropertyName className:(NSString*)className{
	NSMutableString* str = [NSMutableString stringWithCapacity:1024];
	if(self.propertyName){
		[str appendString:thePropertyName];
	}
	else{
		//TODO : here verify if we really use inheritance for object ...
		if(CKStyleClassNamesCache == nil){
			CKStyleClassNamesCache = [[NSMutableDictionary alloc]init];
		}
		[str appendString:className];
	}
	
	//append subProperties
	
	if([properties count] > 0){
		[str appendString:@"["];
	}
	
	int i =0;
	for(NSString* subPropertyName in properties){
		CKObjectProperty* property = [CKObjectProperty propertyWithObject:object keyPath:subPropertyName];
		NSString* valueString = [NSValueTransformer transformProperty:property toClass:[NSString class]];
		[str appendFormat:@"%@%@='%@'",(i > 0) ? @";" : @"" ,subPropertyName,valueString];
		++i;
	}
	
	if([properties count] > 0){
		[str appendString:@"]"];
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

NSString* CKStyleFormats = @"CKStyleFormats";
NSString* CKStyleParentStyle = @"CKStyleParentStyle";
NSString* CKStyleEmptyStyle = @"CKStyleEmptyStyle";
NSString* CKStyleInherits = @"@inherits";
NSString* CKStyleImport = @"@import";

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

- (void)setStyle:(NSMutableDictionary*)style forKey:(NSString*)key{
	[self setObject:style forKey:key];

	CKStyleFormat* format = [[[CKStyleFormat alloc]initFormatWithFormat:key]autorelease];
	[self setFormat:format];
}

- (NSMutableDictionary*)findStyleInHierarchy:(NSString*)key{
	NSMutableDictionary* style = self;
	while(style != nil){
		NSMutableDictionary* foundStyle = [style objectForKey:key];
		if(foundStyle && foundStyle != self){
			return foundStyle;
		}
		style = [style parentStyle];
	}
	return nil;
}

- (void)applyHierarchically:(NSDictionary*)source toDictionary:(NSDictionary*)target forKey:(NSString*)identifier{
	NSMutableDictionary* mutableTarget = [NSMutableDictionary dictionaryWithDictionary:target];
	[self setObject:mutableTarget forKey:identifier];
	
	for(id key in [source allKeys]){
		if([key isEqual:CKStyleParentStyle] == NO
		   && [key isEqual:CKStyleEmptyStyle] == NO
		   && [key isEqual:CKStyleFormats] == NO){
			id sourceObject = [source objectForKey:key];
			if([mutableTarget containsObjectForKey:key] == NO){
				if([sourceObject isKindOfClass:[NSDictionary class]]){
					[mutableTarget setObject:[NSMutableDictionary dictionaryWithDictionary:sourceObject] forKey:key];
				}
				else{
					[mutableTarget setObject:sourceObject forKey:key];
				}
			}
			else if([sourceObject isKindOfClass:[NSMutableDictionary class]]){
				[self applyHierarchically:sourceObject toDictionary:[mutableTarget objectForKey:key] forKey:key];
			}
		}
	}
}

- (void)makeAllInherits{
	NSArray* inheritsArray = [self objectForKey:CKStyleInherits];
	if(inheritsArray){
		for(NSString* key in inheritsArray){
			NSString* normalizedKey = [CKStyleFormat normalizeFormat:key];
			NSMutableDictionary* inheritedStyle = [self findStyleInHierarchy:normalizedKey];
			if(inheritedStyle != nil){
				//ensure inherits is threated on inheritedStyle
				[inheritedStyle makeAllInherits];
				//Apply inheritedStyle to self
				for(NSString* obj in [inheritedStyle allKeys]){
					if([obj isEqual:CKStyleParentStyle] == NO
					   && [obj isEqual:CKStyleEmptyStyle] == NO
					   && [obj isEqual:CKStyleFormats] == NO){
						id inheritedObject = [inheritedStyle objectForKey:obj];
						if([self containsObjectForKey:obj] == NO){
							if([inheritedObject isKindOfClass:[NSDictionary class]]){
								[self setObject:[NSMutableDictionary dictionaryWithDictionary:inheritedObject] forKey:obj];
							}
							else{
								[self setObject:inheritedObject forKey:obj];
							}
						}
						else if([inheritedObject isKindOfClass:[NSDictionary class]]){
							[self applyHierarchically:inheritedObject toDictionary:[self objectForKey:obj] forKey:obj];
						}
					}
				}
			}
		}
		[self removeObjectForKey:CKStyleInherits];
	}
}

- (NSArray*)parseFormatGroups:(NSString*)formats{
	NSArray* components = [formats componentsSeparatedByString:@","];
	NSMutableArray* results = [NSMutableArray array];
	for(NSString* format in components){
		NSString* result = [CKStyleFormat normalizeFormat:format];
		[results addObject:result];
	}
	return results;
}


- (void)processImports{
	NSArray* importArray = [self objectForKey:CKStyleImport];
	for(NSString* import in importArray){
		[[CKStyleManager defaultManager]importContentOfFileNamed:import];
	}
	[self removeObjectForKey:CKStyleImport];
	
	for(id key in [self allKeys]){
		id object = [self objectForKey:key];
		if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKStyleFormats] == NO
		   && [key isEqual:CKStyleParentStyle] == NO
		   && [key isEqual:CKStyleEmptyStyle] == NO){
			NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:object];
			[dico processImports];
		}
	}
}

- (void)initAfterLoading{
	for(id key in [self allKeys]){
		id object = [self objectForKey:key];
		if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKStyleFormats] == NO
		   && [key isEqual:CKStyleParentStyle] == NO
		   && [key isEqual:CKStyleEmptyStyle] == NO){
			NSArray* fromatGroups = [self parseFormatGroups:key];
			[self removeObjectForKey:key];
			
			for(NSString* format in fromatGroups){
				NSMutableDictionary* dico = [NSMutableDictionary dictionaryWithDictionary:object];
				[self setObject:dico forKey:format];
				[dico setObject:[NSValue valueWithNonretainedObject:self] forKey:CKStyleParentStyle];
				[dico initAfterLoading];
			}
		}
	}
}

- (void)postInitAfterLoading{
	[self makeAllInherits];
	for(id key in [self allKeys]){
		id object = [self objectForKey:key];
		if([object isKindOfClass:[NSDictionary class]]
		   && [key isEqual:CKStyleFormats] == NO
		   && [key isEqual:CKStyleParentStyle] == NO
		   && [key isEqual:CKStyleEmptyStyle] == NO){
			
			CKStyleFormat* format = [[[CKStyleFormat alloc]initFormatWithFormat:key]autorelease];
			[self setFormat:format];
			
			[object postInitAfterLoading];
			[object setObject:[NSValue valueWithNonretainedObject:self] forKey:CKStyleParentStyle];
		}
	}
	
	//set the empty style
	NSMutableDictionary* emptyStyle = [NSMutableDictionary dictionary];
	[emptyStyle setObject:[NSValue valueWithNonretainedObject:self] forKey:CKStyleParentStyle];
	[self setObject:emptyStyle forKey:CKStyleEmptyStyle];
}

//Search a style responding to the format in the current scope
- (NSMutableDictionary*)_styleForObject:(id)object format:(CKStyleFormat*)format propertyName:(NSString*)propertyName className:(NSString*)className{
	NSString* objectFormatKey = [format formatForObject:object propertyName:propertyName className:className];
	return [self objectForKey:objectFormatKey];
}


//Search a style responding to the formats in the current scope
- (NSMutableDictionary*)_styleForObject:(id)object formats:(NSArray*)formats propertyName:(NSString*)propertyName className:(NSString*)className{
	for(CKStyleFormat* format in formats){
		NSMutableDictionary* style = [self _styleForObject:object format:format propertyName:propertyName className:className];
		if(style){
			return style;
		}
	}
	return nil;
}

//Search a style in the current scope
- (NSMutableDictionary*)_styleForObject:(id)object propertyName:(NSString*)propertyName{
	NSDictionary* allFormats = [self objectForKey:CKStyleFormats];
	if(allFormats){
		NSArray* propertyformats = [allFormats objectForKey:propertyName];
		if(propertyformats){
			NSMutableDictionary* style = [self _styleForObject:object formats:propertyformats propertyName:propertyName className:nil];
			if(style){
				return style;
			}
		}
		
		Class type = [object class];
		while(type != nil){
			NSString* className = [CKStyleClassNamesCache objectForKey:type];
			if(className == nil){
				className = [type description];
				//className = [className stringByReplacingOccurrencesOfString:@"_MAZeroingWeakRefSubclass" withString:@""];
				[CKStyleClassNamesCache setObject:className forKey:type];
			}
			
			NSArray* formats = [allFormats objectForKey:type];
			if(formats){
				NSMutableDictionary* style = [self _styleForObject:object formats:formats propertyName:propertyName  className:className];
				if(style){
					return style;
				}
			}
			type = class_getSuperclass(type);
		}
	}	
	return nil;
}

//Search a style in the current scope and its parents
- (NSMutableDictionary*)_styleForObjectWithCascading:(id)object propertyName:(NSString*)propertyName{
	NSMutableDictionary* foundStyle = [self _styleForObject:object propertyName:propertyName];
	if(foundStyle){
		return foundStyle;
	}
	
	//Cascading
	NSMutableDictionary* parentStyle = [self parentStyle];
	if(parentStyle){
		NSMutableDictionary* foundStyle = [parentStyle _styleForObjectWithCascading:object propertyName:propertyName];
		if(foundStyle){
			return foundStyle;
		}
	}
	return nil;
}	

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
	NSMutableDictionary* foundStyle = [self _styleForObjectWithCascading:object propertyName:propertyName];
	if(foundStyle){
		return foundStyle;
	}
	
	id emptyStyle = [self objectForKey:CKStyleEmptyStyle];
	return (emptyStyle != nil) ? emptyStyle : self;
}

- (NSMutableDictionary*)parentStyle{
	return [[self objectForKey:CKStyleParentStyle]nonretainedObjectValue];
}

- (BOOL)isEmpty{
	NSInteger count = [self count];
	if([self containsObjectForKey:CKStyleFormats]) --count;
	if([self containsObjectForKey:CKStyleParentStyle]) --count;
	if([self containsObjectForKey:CKStyleEmptyStyle]) --count;
	return count == 0;
}


@end
