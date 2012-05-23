//
//  CKClassPropertyDescriptor.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKClassPropertyDescriptor.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKNSObject+CKRuntime.h"
#import "CKNSObject+CKRuntime_private.h"
#import <objc/runtime.h>
#import <MapKit/MapKit.h>

typedef struct CKStructParsedAttributes{
	NSString* className;
	NSString* encoding;
	NSInteger size;
    BOOL pointer;
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
	else if([results.className isEqual:@"CGAffineTransform"]){
		results.encoding = [NSString stringWithUTF8String:@encode(CGAffineTransform)];
		results.size = sizeof(CGAffineTransform);
	}
    else if([results.className isEqual:@"UIEdgeInsets"]){
		results.encoding = [NSString stringWithUTF8String:@encode(UIEdgeInsets)];
		results.size = sizeof(UIEdgeInsets);
	}
	else if([attributes hasPrefix:@"T{?=\"latitude\"d\"longitude\"d}"]
            || [attributes hasPrefix:@"T{?=dd}"]){//We assume unknown type here is a CLLocationCoordinate2D ...
		results.encoding = [NSString stringWithUTF8String:@encode(CLLocationCoordinate2D)];
		results.size = sizeof(CLLocationCoordinate2D);
		results.className = @"CLLocationCoordinate2D";
	}
	else{
		results.encoding = nil;
		results.size = 0;
		//NSAssert(NO,@"type '%@' not supported yet !",results.className);
	}
    results.pointer = NO;
	return results;
}

CKStructParsedAttributes parseStructPointerAttributes(NSString* attributes){
	CKStructParsedAttributes results;
	NSRange rangeForClassName = [attributes rangeOfString:@"="];
	results.className = [attributes substringWithRange:NSMakeRange(3,rangeForClassName.location - 3)];
	
	//FIXME : later do it properly by registering descriptors for structs, ...
	if([results.className hasPrefix:@"CGColor"]){
		results.encoding = [NSString stringWithUTF8String:@encode(CGColorRef)];
		results.size = sizeof(CGColorRef);
		results.className = @"CGColorRef";
	}
    else{
		results.encoding = nil;
		results.size = 0;
		//NSAssert(NO,@"type '%@' not supported yet !",results.className);
	}
    results.pointer = YES;
	return results;
}


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
@synthesize extendedAttributesSelector;
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
	if([subStrings count] >= 2){
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
    else if([attributes hasPrefix:@"T^{"]){
		self.propertyType = CKClassPropertyDescriptorTypeStructPointer;
		CKStructParsedAttributes result = parseStructPointerAttributes(attributes);
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
	descriptor.extendedAttributesSelector = [NSObject propertyExtendedAttributesSelectorForProperty:name];
	if([NSObject isClass:c kindOfClass:[NSArray class]]){
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
	descriptor.extendedAttributesSelector = [NSObject propertyExtendedAttributesSelectorForProperty:name];
	return descriptor;
}


+ (CKClassPropertyDescriptor*) classDescriptorForNativePropertyNamed:(NSString*)name nativeType:(CKClassPropertyDescriptorType)type readOnly:(BOOL)readOnly{
	CKClassPropertyDescriptor* descriptor = [[[CKClassPropertyDescriptor alloc]init]autorelease];
	descriptor.name = name;
    switch(type){
        case CKClassPropertyDescriptorTypeChar:              { descriptor.encoding =  @"c"; descriptor.typeSize = sizeof(char);break; }
        case CKClassPropertyDescriptorTypeInt:               { descriptor.encoding =  @"i"; descriptor.typeSize = sizeof(int);break; }
        case CKClassPropertyDescriptorTypeShort:             { descriptor.encoding =  @"s"; descriptor.typeSize = sizeof(short);break; }
        case CKClassPropertyDescriptorTypeLong:              { descriptor.encoding =  @"l"; descriptor.typeSize = sizeof(long);break; }
        case CKClassPropertyDescriptorTypeLongLong:          { descriptor.encoding =  @"q"; descriptor.typeSize = sizeof(long long);break; }
        case CKClassPropertyDescriptorTypeUnsignedChar:      { descriptor.encoding =  @"C"; descriptor.typeSize = sizeof(unsigned char);break; }
        case CKClassPropertyDescriptorTypeUnsignedInt:       { descriptor.encoding =  @"I"; descriptor.typeSize = sizeof(unsigned int);break; }
        case CKClassPropertyDescriptorTypeUnsignedShort:     { descriptor.encoding =  @"S"; descriptor.typeSize = sizeof(unsigned short);break; }
        case CKClassPropertyDescriptorTypeUnsignedLong:      { descriptor.encoding =  @"L"; descriptor.typeSize = sizeof(unsigned long);break; }
        case CKClassPropertyDescriptorTypeUnsignedLongLong:  { descriptor.encoding =  @"Q"; descriptor.typeSize = sizeof(unsigned long long);break; }
        case CKClassPropertyDescriptorTypeFloat:             { descriptor.encoding =  @"f"; descriptor.typeSize = sizeof(float);break; }
        case CKClassPropertyDescriptorTypeDouble:            { descriptor.encoding =  @"d"; descriptor.typeSize = sizeof(double);break; }
        case CKClassPropertyDescriptorTypeCppBool:           { descriptor.encoding =  @"B"; descriptor.typeSize = sizeof(bool);break; }
        case CKClassPropertyDescriptorTypeVoid:              { descriptor.encoding =  @"v"; descriptor.typeSize = sizeof(void);break; }
        case CKClassPropertyDescriptorTypeCharString:        { descriptor.encoding =  @"*"; descriptor.typeSize = sizeof(char*);break; }
        case CKClassPropertyDescriptorTypeClass:             { descriptor.encoding =  @"#"; descriptor.typeSize = sizeof(Class);break; }
        case CKClassPropertyDescriptorTypeSelector:          { descriptor.encoding =  @":"; descriptor.typeSize = sizeof(SEL);break; }
    }
    descriptor.propertyType = type;
	descriptor.assignementType = CKClassPropertyDescriptorAssignementTypeAssign;
	descriptor.isReadOnly = readOnly;
	descriptor.extendedAttributesSelector = [NSObject propertyExtendedAttributesSelectorForProperty:name];
    return descriptor;
}

+ (CKClassPropertyDescriptor*) boolDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly{
    return [CKClassPropertyDescriptor classDescriptorForNativePropertyNamed:name nativeType:CKClassPropertyDescriptorTypeChar readOnly:readOnly];
}

+ (CKClassPropertyDescriptor*) floatDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly{
    return [CKClassPropertyDescriptor classDescriptorForNativePropertyNamed:name nativeType:CKClassPropertyDescriptorTypeFloat readOnly:readOnly];
}

+ (CKClassPropertyDescriptor*) intDescriptorForPropertyNamed:(NSString*)name readOnly:(BOOL)readOnly{
    return [CKClassPropertyDescriptor classDescriptorForNativePropertyNamed:name nativeType:CKClassPropertyDescriptorTypeInt readOnly:readOnly];
}


- (CKPropertyExtendedAttributes*)extendedAttributesForInstance:(id)instance{
    return [CKPropertyExtendedAttributes extendedAttributesForObject:instance property:self];
}

@end



@interface CKClassPropertyDescriptorManager ()
@property (nonatomic, retain, readwrite) NSMutableDictionary *propertiesByClassName;
@property (nonatomic, retain, readwrite) NSMutableDictionary *propertiesByClassNameByName;
@property (nonatomic, retain, readwrite) NSMutableDictionary *propertyNamesByClassName;
@property (nonatomic, retain, readwrite) NSMutableDictionary *viewPropertiesByClassName;
@end

static CKClassPropertyDescriptorManager* CCKClassPropertyDescriptorManagerDefault = nil;
@implementation CKClassPropertyDescriptorManager
@synthesize propertiesByClassName = _propertiesByClassName;
@synthesize propertiesByClassNameByName = _propertiesByClassNameByName;
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
	self.propertiesByClassName = [NSMutableDictionary dictionaryWithCapacity:500];
	self.propertyNamesByClassName = [NSMutableDictionary dictionaryWithCapacity:500];
	self.viewPropertiesByClassName = [NSMutableDictionary dictionaryWithCapacity:500];
	self.propertiesByClassNameByName = [NSMutableDictionary dictionaryWithCapacity:500];
	return self;
}

- (void)dealloc{
	self.propertiesByClassName = nil;
	self.viewPropertiesByClassName = nil;
	self.propertyNamesByClassName = nil;
	self.propertiesByClassNameByName = nil;
	[super dealloc];
}

- (NSArray*)allPropertiesForClass:(Class)class{
    @synchronized(self){
        NSString* className = [NSString stringWithUTF8String:class_getName(class)];
        NSMutableArray* allProperties = [_propertiesByClassName objectForKey:className];
        if(allProperties == nil){
            allProperties = [NSMutableArray array];
            [NSObject introspection:class array:allProperties];
            [_propertiesByClassName setObject:allProperties forKey:className];
            
            NSMutableDictionary* propertiesByName = [NSMutableDictionary dictionaryWithCapacity:[allProperties count]];
            NSMutableArray* allPropertyNames = [NSMutableArray arrayWithCapacity:[allProperties count]];
            NSMutableArray* allViewPropertyDescriptors = [NSMutableArray arrayWithCapacity:[allProperties count]];
            for(CKClassPropertyDescriptor* property in allProperties){
                [allPropertyNames addObject:property.name];
                if([NSObject isClass:property.type kindOfClass:[UIView class]]){
                    [allViewPropertyDescriptors addObject:property];
                }
                [propertiesByName setObject:property forKey:property.name];
            }
            [_propertyNamesByClassName setObject:allPropertyNames forKey:className];
            [_viewPropertiesByClassName setObject:allViewPropertyDescriptors forKey:className];
            [_propertiesByClassNameByName setObject:propertiesByName forKey:className];
        }
        
        return allProperties;
    }
}

- (void)addPropertyDescriptor:(CKClassPropertyDescriptor*)descriptor forClass:(Class)c{
    @synchronized(self){
        NSString* className = [NSString stringWithUTF8String:class_getName(c)];
        NSAssert([_propertiesByClassName objectForKey:className],@"Could not add properties to non introspected class");
        NSMutableArray* allProperties = [_propertiesByClassName objectForKey:className];
        [allProperties addObject:descriptor];
        
        NSMutableArray* allPropertiesNames = [_propertyNamesByClassName objectForKey:className];
        [allPropertiesNames addObject:descriptor.name];
        
        if([NSObject isClass:descriptor.type kindOfClass:[UIView class]]){
            NSMutableArray* allViewsProperties = [_viewPropertiesByClassName objectForKey:className];
            [allViewsProperties addObject:descriptor];
        }
        
        NSMutableDictionary* propertiesByName = [_propertiesByClassNameByName objectForKey:className];
        [propertiesByName setObject:descriptor forKey:descriptor.name];
    }
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
	NSString* className = [NSString stringWithUTF8String:class_getName(class)];
    NSMutableDictionary* propertiesByName = [_propertiesByClassNameByName objectForKey:className];
    if(!propertiesByName){
        [self allPropertiesForClass:class];
        propertiesByName = [_propertiesByClassNameByName objectForKey:className];
    }
    return [propertiesByName objectForKey:name];
}

@end


