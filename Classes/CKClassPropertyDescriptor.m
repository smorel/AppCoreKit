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

typedef struct CKStructParsedAttributes{
	NSString* className;
	NSString* encoding;
	NSInteger size;
}CKStructParsedAttributes;

CKStructParsedAttributes parseStructAttributes(NSString* attributes){
	CKStructParsedAttributes results;
	NSRange rangeForClassName = [attributes rangeOfString:@"="];
	results.className = [attributes substringWithRange:NSMakeRange(2,rangeForClassName.location - 2)];
	
	//FIXME : later do it properly by registering descriptors for structs, ...
	if([results.className isEqual:@"CGSize"]){
		results.encoding = [NSString stringWithUTF8String:@encode(CGSize)];
		results.size = sizeof(CGSize);
	}
	else if([results.className isEqual:@"CGRect"]){
		results.encoding = [NSString stringWithUTF8String:@encode(CGRect)];
		results.size = sizeof(CGRect);
	}
	else if([results.className isEqual:@"CGPoint"]){
		results.encoding = [NSString stringWithUTF8String:@encode(CGPoint)];
		results.size = sizeof(CGPoint);
	}
	else{
		results.encoding = nil;
		results.size = 0;
		//NSAssert(NO,@"type '%@' not supported yet !",results.className);
	}
	return results;
}

/*
 NSRange rangeForClassName = [attributes rangeOfString:@"="];
 self.className = [attributes substringWithRange:NSMakeRange(2,rangeForClassName.location - 2)];
 NSRange rangeForEnd = [attributes rangeOfString:@"}"];
 NSString* attributesEncoding = [attributes substringWithRange:NSMakeRange(rangeForClassName.location + 2,rangeForEnd.location - (rangeForClassName.location + 2) )];
 NSArray* encodingComponents = [attributesEncoding componentsSeparatedByString:@"\""];
 
 NSInteger size = 0;
 NSMutableString* theencoding = [NSMutableString stringWithFormat:@"{%@=",self.className];
 for(int i= 1; i < [encodingComponents count]; i += 2){
 NSString* e = [encodingComponents objectAtIndex:i];
 [theencoding appendString:e];
 if([e isEqual:@"@"]){size += sizeof(NSObject*);}
 else if([e isEqual:@"c"]){size += sizeof(char);}
 else if([e isEqual:@"i"]){size += sizeof(NSInteger);}
 else if([e isEqual:@"s"]){size += sizeof(short);}
 else if([e isEqual:@"l"]){size += sizeof(long);}
 else if([e isEqual:@"q"]){size += sizeof(long long);}
 else if([e isEqual:@"C"]){size += sizeof(unsigned char);}
 else if([e isEqual:@"I"]){size += sizeof(NSUInteger);}
 else if([e isEqual:@"S"]){size += sizeof(unsigned short);}
 else if([e isEqual:@"L"]){size += sizeof(unsigned long);}
 else if([e isEqual:@"Q"]){size += sizeof(unsigned long long);}
 else if([e isEqual:@"f"]){size += sizeof(CGFloat);}
 else if([e isEqual:@"d"]){size += sizeof(double);}
 else if([e isEqual:@"B"]){size += sizeof(BOOL);}
 else if([e isEqual:@"v"]){size += sizeof(void*);}
 else if([e isEqual:@"*"]){size += sizeof(char*);}
 else if([e isEqual:@"#"]){size += sizeof(Class);}
 else if([e isEqual:@":"]){size += sizeof(SEL);}
 else if([e hasPrefix:@"{"]){NSAssert(NO,@"not supported");}
 }
 [theencoding appendString:@"}"];
 */


@implementation CKClassPropertyDescriptor
@synthesize name;
@synthesize type;
@synthesize attributes;
@synthesize propertyType;
@synthesize assignementType;
@synthesize isReadOnly;
@synthesize className;
@synthesize encoding;
@synthesize typeSize;
@synthesize metaDataSelector;
@synthesize insertSelector;
@synthesize removeSelector;
@synthesize removeAllSelector;

- (void)dealloc{
	self.name = nil;
	self.attributes = nil;
	self.className = nil;
	self.encoding = nil;
	[super dealloc];
}

- (NSString*) description{
	return [NSString stringWithFormat:@"%@",name];
}

-(NSString*)getTypeDescriptor{
	return [attributes substringWithRange: NSMakeRange(1,2)];
}

- (NSString*)className{
	return className;
}

- (void)setAttributes:(NSString *)att{
	[attributes release];
	attributes = [att retain];
	
	assignementType = CKClassPropertyDescriptorAssignementTypeAssign;
	NSArray * subStrings = [attributes componentsSeparatedByString:@","];
	
	self.isReadOnly = NO;
	if([subStrings count] > 2){
		for(int i = 1; i < [subStrings count] - 1; ++i){
			NSString* assignementAttribute = [subStrings objectAtIndex:i];
			if([assignementAttribute isEqual:@"&"]){
				assignementType = CKClassPropertyDescriptorAssignementTypeRetain;
			}
			else if([assignementAttribute isEqual:@"C"]){
				assignementType = CKClassPropertyDescriptorAssignementTypeCopy;
			}
			else if([assignementAttribute isEqual:@"W"]){
				assignementType = CKClassPropertyDescriptorAssignementTypeWeak;
			}
			else if([assignementAttribute isEqual:@"R"]){
				self.isReadOnly = YES;
			}
		}
	}	
	
	if([attributes hasPrefix:@"T@"]){
		self.propertyType = CKClassPropertyDescriptorTypeObject;
		self.encoding = @"@";
		//FIXME sizeof(class)
		self.typeSize = sizeof(NSObject*);
	}
	else if([attributes hasPrefix:@"Tc"]){
		self.propertyType = CKClassPropertyDescriptorTypeChar;
		self.encoding = @"c";
		self.typeSize = sizeof(char);
	}
	else if([attributes hasPrefix:@"Ti"]){
		self.propertyType = CKClassPropertyDescriptorTypeInt;
		self.encoding = @"i";
		self.typeSize = sizeof(NSInteger);
	}
	else if([attributes hasPrefix:@"Ts"]){
		self.propertyType = CKClassPropertyDescriptorTypeShort;
		self.encoding = @"s";
		self.typeSize = sizeof(short);
	}
	else if([attributes hasPrefix:@"Tl"]){
		self.propertyType = CKClassPropertyDescriptorTypeLong;
		self.encoding = @"l";
		self.typeSize = sizeof(long);
	}
	else if([attributes hasPrefix:@"Tq"]){
		self.propertyType = CKClassPropertyDescriptorTypeLongLong;
		self.encoding = @"q";
		self.typeSize = sizeof(long long);
	}
	else if([attributes hasPrefix:@"TC"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedChar;
		self.encoding = @"C";
		self.typeSize = sizeof(unsigned char);
	}
	else if([attributes hasPrefix:@"TI"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedInt;
		self.encoding = @"I";
		self.typeSize = sizeof(NSUInteger);
	}
	else if([attributes hasPrefix:@"TS"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedShort;
		self.encoding = @"S";
		self.typeSize = sizeof(unsigned short);
	}
	else if([attributes hasPrefix:@"TL"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedLong;
		self.encoding = @"L";
		self.typeSize = sizeof(unsigned long);
	}
	else if([attributes hasPrefix:@"TQ"]){
		self.propertyType = CKClassPropertyDescriptorTypeUnsignedLongLong;
		self.encoding = @"Q";
		self.typeSize = sizeof(unsigned long long);
	}
	else if([attributes hasPrefix:@"Tf"]){
		self.propertyType = CKClassPropertyDescriptorTypeFloat;
		self.encoding = @"f";
		self.typeSize = sizeof(float);
	}
	else if([attributes hasPrefix:@"Td"]){
		self.propertyType = CKClassPropertyDescriptorTypeDouble;
		self.encoding = @"d";
		self.typeSize = sizeof(double);
	}
	else if([attributes hasPrefix:@"TB"]){
		self.propertyType = CKClassPropertyDescriptorTypeCppBool;
		self.encoding = @"B";
		self.typeSize = sizeof(BOOL);
	}
	else if([attributes hasPrefix:@"Tv"]){
		self.propertyType = CKClassPropertyDescriptorTypeVoid;
		self.encoding = @"v";
		self.typeSize = sizeof(void*);
	}
	else if([attributes hasPrefix:@"T*"]){
		self.propertyType = CKClassPropertyDescriptorTypeCharString;
		self.encoding = @"*";
		self.typeSize = sizeof(char*);
	}
	else if([attributes hasPrefix:@"T#"]){
		self.propertyType = CKClassPropertyDescriptorTypeClass;
		self.encoding = @"#";
		self.typeSize = sizeof(Class);
	}
	else if([attributes hasPrefix:@"T:"]){
		self.propertyType = CKClassPropertyDescriptorTypeSelector;
		self.encoding = @":";
		self.typeSize = sizeof(SEL);
	}
	else if([attributes hasPrefix:@"T{"]){
		self.propertyType = CKClassPropertyDescriptorTypeStruct;
		CKStructParsedAttributes result = parseStructAttributes(attributes);
		self.className = result.className;
		self.encoding = result.encoding;
		self.typeSize = result.size;
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


+ (CKClassPropertyDescriptor*) classDescriptorForPropertyNamed:(NSString*)name withClass:(Class)c assignment:(CKClassPropertyDescriptorAssignementType)assignment readOnly:(BOOL)readOnly{
	CKClassPropertyDescriptor* descriptor = [[[CKClassPropertyDescriptor alloc]init]autorelease];
	descriptor.name = name;
	descriptor.className = [c description];
	descriptor.encoding = @"@";
	descriptor.typeSize = sizeof(c);
	descriptor.propertyType = CKClassPropertyDescriptorTypeObject;
	descriptor.assignementType = assignment;
	descriptor.type = c;
	descriptor.isReadOnly = readOnly;
	descriptor.metaDataSelector = [NSObject propertyMetaDataSelectorForProperty:name];
	if([NSObject isKindOf:c parentType:[NSArray class]]){
		descriptor.insertSelector = [NSObject insertSelectorForProperty:name];
		descriptor.removeSelector = [NSObject removeSelectorForProperty:name];
		descriptor.removeAllSelector = [NSObject removeAllSelectorForProperty:name];
	}
	return descriptor;
}

+ (CKClassPropertyDescriptor*) structDescriptorForPropertyNamed:(NSString*)name structName:(NSString*)structName structEncoding:(NSString*)encoding structSize:(NSInteger)size readOnly:(BOOL)readOnly{
	CKClassPropertyDescriptor* descriptor = [[[CKClassPropertyDescriptor alloc]init]autorelease];
	descriptor.name = name;
	descriptor.className = structName;
	descriptor.encoding = encoding;
	descriptor.typeSize = size;
	descriptor.propertyType = CKClassPropertyDescriptorTypeStruct;
	descriptor.assignementType = CKClassPropertyDescriptorAssignementTypeAssign;
	descriptor.type = nil;
	descriptor.isReadOnly = readOnly;
	descriptor.metaDataSelector = [NSObject propertyMetaDataSelectorForProperty:name];
	return descriptor;
}

+ (CKClassPropertyDescriptor*) boolDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly{
	CKClassPropertyDescriptor* descriptor = [[[CKClassPropertyDescriptor alloc]init]autorelease];
	descriptor.name = name;
	descriptor.encoding = @"c";
	descriptor.typeSize = sizeof(char);
	descriptor.propertyType = CKClassPropertyDescriptorTypeChar;
	descriptor.assignementType = CKClassPropertyDescriptorAssignementTypeAssign;
	descriptor.isReadOnly = readOnly;
	descriptor.metaDataSelector = [NSObject propertyMetaDataSelectorForProperty:name];
	return descriptor;	
}

+ (CKClassPropertyDescriptor*) floatDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly{
	CKClassPropertyDescriptor* descriptor = [[[CKClassPropertyDescriptor alloc]init]autorelease];
	descriptor.name = name;
	descriptor.encoding = @"f";
	descriptor.typeSize = sizeof(float);
	descriptor.propertyType = CKClassPropertyDescriptorTypeFloat;
	descriptor.assignementType = CKClassPropertyDescriptorAssignementTypeAssign;
	descriptor.isReadOnly = readOnly;
	descriptor.metaDataSelector = [NSObject propertyMetaDataSelectorForProperty:name];
	return descriptor;	
}

+ (CKClassPropertyDescriptor*) intDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly{
	CKClassPropertyDescriptor* descriptor = [[[CKClassPropertyDescriptor alloc]init]autorelease];
	descriptor.name = name;
	descriptor.encoding = @"i";
	descriptor.typeSize = sizeof(NSInteger);
	descriptor.propertyType = CKClassPropertyDescriptorTypeInt;
	descriptor.assignementType = CKClassPropertyDescriptorAssignementTypeAssign;
	descriptor.isReadOnly = readOnly;
	descriptor.metaDataSelector = [NSObject propertyMetaDataSelectorForProperty:name];
	return descriptor;
}

@end



@interface CKClassPropertyDescriptorManager ()
@property (nonatomic, retain, readwrite) NSDictionary *propertiesByClassName;
@property (nonatomic, retain, readwrite) NSDictionary *propertyNamesByClassName;
@property (nonatomic, retain, readwrite) NSDictionary *viewPropertiesByClassName;
@end

static CKClassPropertyDescriptorManager* CCKClassPropertyDescriptorManagerDefault = nil;
@implementation CKClassPropertyDescriptorManager
@synthesize propertiesByClassName = _propertiesByClassName;
@synthesize propertyNamesByClassName = _propertyNamesByClassName;
@synthesize viewPropertiesByClassName = _viewPropertiesByClassName;

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
	self.viewPropertiesByClassName = [NSMutableDictionary dictionary];
	return self;
}

- (void)dealloc{
	self.propertiesByClassName = nil;
	self.viewPropertiesByClassName = nil;
	self.propertyNamesByClassName = nil;
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
		NSMutableArray* allViewPropertyDescriptors = [NSMutableArray array];
		for(CKClassPropertyDescriptor* property in allProperties){
			[allPropertyNames addObject:property.name];
			if([NSObject isKindOf:property.type parentType:[UIView class]]){
				[allViewPropertyDescriptors addObject:property];
			}
		}
		[_propertyNamesByClassName setObject:allPropertyNames forKey:className];
		[_viewPropertiesByClassName setObject:allViewPropertyDescriptors forKey:className];
	}
	
	return allProperties;
}


- (NSArray*)allViewsPropertyForClass:(Class)class{
	NSString* className = [NSString stringWithUTF8String:class_getName(class)];
	NSMutableArray* allViewProperties = [_viewPropertiesByClassName objectForKey:className];
	if(allViewProperties == nil){
		[self allPropertiesForClass:class];
		allViewProperties = [_viewPropertiesByClassName objectForKey:className];
	}
	return allViewProperties;
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

/*
- (NSArray*)allPropertiesForStruct:(NSString*)name{
	NSMutableArray* allProperties = [_propertiesByClassName objectForKey:name];
	return allProperties;
}

- (NSArray*)allPropertieNamesForStruct:(NSString*)name{
	NSMutableArray* allPropertyNames = [_propertyNamesByClassName objectForKey:name];
	return allPropertyNames;
}

- (CKClassPropertyDescriptor*)property:(NSString*)name forStruct:(NSString*)structname{
	NSArray* properties = [self allPropertiesForStruct:structname];
	//TODO : Optimize this by getting a dictionary of properties instead of an array !
	for(CKClassPropertyDescriptor* p in properties){
		if([p.name isEqual:name])
			return p;
	}
	return nil;
}

- (void)registerPropertyDescriptors:(NSArray*)propertyDescriptors forStructName:(NSString*)name{
	[_propertiesByClassName setObject:propertyDescriptors forKey:name];
	NSMutableArray* allPropertyNames = [NSMutableArray array];
	for(CKClassPropertyDescriptor* p in propertyDescriptors){
		[allPropertyNames addObject:p.name];
	}
	[_propertyNamesByClassName setObject:allPropertyNames forKey:name];
}*/

@end


