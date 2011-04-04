//
//  CKClassPropertyDescriptor.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKClassPropertyDescriptor.h"
#import "CKNSObject+Introspection.h"
#import <objc/runtime.h>

@implementation CKClassPropertyDescriptor
@synthesize name;
@synthesize type;
@synthesize attributes;
@synthesize metaDataSelector;
@synthesize propertyType;
@synthesize assignementType;

- (void)dealloc{
	self.name = nil;
	self.attributes = nil;
	[super dealloc];
}

- (NSString*) description{
	return [NSString stringWithFormat:@"%@",name];
}

-(NSString*)getTypeDescriptor{
	return [attributes substringWithRange: NSMakeRange(1,2)];
}

- (NSString*)className{
	return [NSString stringWithUTF8String:class_getName(self.type)];
}

- (void)setAttributes:(NSString *)att{
	[attributes release];
	attributes = [att retain];
	
	assignementType = CKClassPropertyDescriptorAssignementTypeAssign;
	NSArray * subStrings = [attributes componentsSeparatedByString:@","];
	if([subStrings count] > 2){
		NSString* assignementAttribute = [subStrings objectAtIndex:1];
		if([assignementAttribute isEqual:@"&"]){
			assignementType = CKClassPropertyDescriptorAssignementTypeRetain;
		}
		else if([assignementAttribute isEqual:@"C"]){
			assignementType = CKClassPropertyDescriptorAssignementTypeCopy;
		}
		else if([assignementAttribute isEqual:@"W"]){
			assignementType = CKClassPropertyDescriptorAssignementTypeWeak;
		}
	}	
	
	if([attributes hasPrefix:@"T@"]){
		self.propertyType = CKClassPropertyDescriptorTypeObject;
	}
	else if([attributes hasPrefix:@"Tc"]){
		self.propertyType = CKClassPropertyDescriptorTypeChar;
	}
	else if([attributes hasPrefix:@"Ti"]){
		self.propertyType = CKClassPropertyDescriptorTypeInt;
	}
	else if([attributes hasPrefix:@"Ts"]){
		self.propertyType = CKClassPropertyDescriptorTypeShort;
	}
	else if([attributes hasPrefix:@"Tl"]){
		self.propertyType = CKClassPropertyDescriptorTypeLong;
	}
	else if([attributes hasPrefix:@"Tq"]){
		self.propertyType = CKClassPropertyDescriptorTypeLongLong;
	}
	else if([attributes hasPrefix:@"TC"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedChar;
	}
	else if([attributes hasPrefix:@"TI"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedInt;
	}
	else if([attributes hasPrefix:@"TS"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedShort;
	}
	else if([attributes hasPrefix:@"TL"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedLong;
	}
	else if([attributes hasPrefix:@"TQ"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedLongLong;
	}
	else if([attributes hasPrefix:@"Tf"]){
		self.propertyType = CKClassPropertyDescriptorTypeFloat;
	}
	else if([attributes hasPrefix:@"Td"]){
		self.propertyType = CKClassPropertyDescriptorTypeDouble;
	}
	else if([attributes hasPrefix:@"TB"]){
		self.propertyType = CKClassPropertyDescriptorTypeCppBool;
	}
	else if([attributes hasPrefix:@"Tv"]){
		self.propertyType = CKClassPropertyDescriptorTypeVoid;
	}
	else if([attributes hasPrefix:@"T*"]){
		self.propertyType = CKClassPropertyDescriptorTypeCharString;
	}
	else if([attributes hasPrefix:@"T#"]){
		self.propertyType = CKClassPropertyDescriptorTypeClass;
	}
	else if([attributes hasPrefix:@"T:"]){
		self.propertyType = CKClassPropertyDescriptorTypeSelector;
	}
	else{
		/*
		 [array type] : array
		 {name=type...} : structure
		 (name=type...) : union
		 bnum : bit field of num bits
		 ^type : pointer to type
		 ? : unknown type (among other things, this code is used for function pointers)
		 */ 
		
		self.propertyType = CKClassPropertyDescriptorTypeUnknown;
	}	
}

@end



@interface CKClassPropertyDescriptorManager ()
@property (nonatomic, retain, readwrite) NSDictionary *propertiesByClassName;
@property (nonatomic, retain, readwrite) NSDictionary *propertyNamesByClassName;
@end

static CKClassPropertyDescriptorManager* CCKClassPropertyDescriptorManagerDefault = nil;
@implementation CKClassPropertyDescriptorManager
@synthesize propertiesByClassName = _propertiesByClassName;
@synthesize propertyNamesByClassName = _propertyNamesByClassName;

+ (CKClassPropertyDescriptorManager*)defaultManager{
	if(CCKClassPropertyDescriptorManagerDefault == nil){
		CCKClassPropertyDescriptorManagerDefault = [[CKClassPropertyDescriptorManager alloc]init];
	}
	return CCKClassPropertyDescriptorManagerDefault;
}

- (id)init{
	[super init];
	self.propertiesByClassName = [NSMutableDictionary dictionary];
	self.propertyNamesByClassName = [NSMutableDictionary dictionary];
	return self;
}

- (void)dealloc{
	self.propertiesByClassName = nil;
	[super dealloc];
}

- (NSArray*)allPropertiesForClass:(Class)class{
	NSString* className = [NSString stringWithUTF8String:class_getName(class)];
	NSMutableArray* allProperties = [_propertiesByClassName objectForKey:className];
	if(allProperties == nil){
		allProperties = [NSMutableArray array];
		[NSObject introspection:class array:allProperties];
		[_propertiesByClassName setObject:allProperties forKey:className];
		
		NSMutableArray* allPropertyNames = [NSMutableArray array];
		for(CKClassPropertyDescriptor* property in allProperties){
			[allPropertyNames addObject:property.name];
		}
		[_propertyNamesByClassName setObject:allPropertyNames forKey:className];
	}
	
	return allProperties;
}


- (NSArray*)allPropertieNamesForClass:(Class)class{
	NSString* className = [NSString stringWithUTF8String:class_getName(class)];
	NSMutableArray* allPropertyNames = [_propertyNamesByClassName objectForKey:className];
	if(allPropertyNames == nil){
		[self allPropertiesForClass:class];
		allPropertyNames = [_propertyNamesByClassName objectForKey:className];
	}
	return allPropertyNames;
}

- (CKClassPropertyDescriptor*)property:(NSString*)name forClass:(Class)class{
	NSArray* properties = [self allPropertiesForClass:class];
	//TODO : Optimize this by getting a dictionary of properties instead of an array !
	for(CKClassPropertyDescriptor* p in properties){
		if([p.name isEqual:name])
			return p;
	}
	return nil;
}

@end


