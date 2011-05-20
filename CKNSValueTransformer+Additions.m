//
//  CKSerializer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSValueTransformer+Additions.h"
#import <objc/runtime.h>
#import "CKUIColorAdditions.h"

NSString* CKSerializerClassTag = @"@class";
NSString* CKSerializerIDTag = @"@id";

@interface NSValueTransformer()
+ (id)transform:(id)source toClass:(Class)type inProperty:(CKObjectProperty*)property;
@end

//utiliser des selector au lieu des valueTransformers
@implementation NSValueTransformer (CKAddition)

+ (void)transform:(id)object inProperty:(CKObjectProperty*)property{
	CKClassPropertyDescriptor* descriptor = [property descriptor];
	
	//if no conversion requiered, set the property directly
	if(descriptor.type != nil && [object isKindOfClass:descriptor.type]){
		[property setValue:object];
		return;
	}
	
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeChar:{
			char c = [NSValueTransformer convertCharFromObject:object];
			[property setValue:[NSNumber numberWithChar:c]];
			break;
		}
		case CKClassPropertyDescriptorTypeInt:{
			NSInteger i = [NSValueTransformer convertIntegerFromObject:object];
			[property setValue:[NSNumber numberWithInt:i]];
			break;
		}
		case CKClassPropertyDescriptorTypeShort:{
			short s = [NSValueTransformer convertShortFromObject:object];
			[property setValue:[NSNumber numberWithShort:s]];
			break;
		}
		case CKClassPropertyDescriptorTypeLong:{
			long l = [NSValueTransformer convertLongFromObject:object];
			[property setValue:[NSNumber numberWithLong:l]];
			break;
		}
		case CKClassPropertyDescriptorTypeLongLong:{
			long long ll = [NSValueTransformer convertLongLongFromObject:object];
			[property setValue:[NSNumber numberWithLongLong:ll]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedChar:{
			unsigned char uc = [NSValueTransformer convertUnsignedCharFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedChar:uc]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedInt:{
			NSUInteger ui = [NSValueTransformer convertUnsignedIntFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedInt:ui]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedShort:{
			unsigned short us = [NSValueTransformer convertUnsignedShortFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedShort:us]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedLong:{
			unsigned long ul = [NSValueTransformer convertUnsignedLongFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedLong:ul]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedLongLong:{
			unsigned long long ull = [NSValueTransformer convertUnsignedLongLongFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedLongLong:ull]];
			break;
		}
		case CKClassPropertyDescriptorTypeFloat:{
			CGFloat f = [NSValueTransformer convertFloatFromObject:object];
			[property setValue:[NSNumber numberWithFloat:f]];
			break;
		}
		case CKClassPropertyDescriptorTypeDouble:{
			double d = [NSValueTransformer convertDoubleFromObject:object];
			[property setValue:[NSNumber numberWithDouble:d]];
			break;
		}
		case CKClassPropertyDescriptorTypeCppBool:{
			BOOL bo =  [NSValueTransformer convertBoolFromObject:object];
			[property setValue:[NSNumber numberWithBool:bo]];
			break;
		}
		case CKClassPropertyDescriptorTypeClass:{
			Class c =  [NSValueTransformer convertClassFromObject:object];
			[property setValue:c];
			break;
		}
		case CKClassPropertyDescriptorTypeSelector:{
			SEL s =  [NSValueTransformer convertSelectorFromObject:object];
			[property setValue:[NSValue valueWithPointer:s]];
			break;
		}
		case CKClassPropertyDescriptorTypeObject:{
			[NSValueTransformer transform:object toClass:descriptor.type inProperty:property];
			break;
		}
		case CKClassPropertyDescriptorTypeStruct:{
			NSString* typeName = descriptor.className;
			NSString* selectorName = [NSString stringWithFormat:@"convert%@FromObject:",typeName];
			SEL selector = NSSelectorFromString(selectorName);
			if([[NSValueTransformer class]respondsToSelector:selector]){
				NSMethodSignature *signature = [[NSValueTransformer class] methodSignatureForSelector:selector];
				
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:selector];
				[invocation setTarget:[NSValueTransformer class]];
				[invocation setArgument:&object
								atIndex:2];
				[invocation invoke];
				
				void* returnValue = malloc(descriptor.typeSize);
				[invocation getReturnValue:returnValue];
				
				NSValue* value =  [NSValue value:returnValue withObjCType:[descriptor.encoding UTF8String]];
				[property setValue:value];
			}
			else{
				NSAssert(NO,@"No transform selector for struct of type '%@'",typeName);
			}
			break;
		}
		case CKClassPropertyDescriptorTypeVoid:
		case CKClassPropertyDescriptorTypeCharString:
		case CKClassPropertyDescriptorTypeUnknown:{
			NSAssert(NO,@"Not supported");
			break;
		}
	}
}


+ (id)transform:(id)source toClass:(Class)type inProperty:(CKObjectProperty*)property{
	id propertyValue = [property value];
	
	SEL selector = [type convertFromObjectSelector:source];
	if(selector != nil){
		id result = [type performSelector:selector withObject:source];
		if(property != nil){
			[property setValue:result];
		}
		return result;
	}
	
	selector = [type convertToObjectSelector:source];
	if(selector != nil && propertyValue != nil){
		id result = [[source class] performSelector:selector withObject:propertyValue];
		if(property != nil){
			[property setValue:result];
		}
		return result;
	}
	
	selector = [type valueTransformerObjectSelector:source];
	if(selector != nil){
		id result = [[NSValueTransformer class] performSelector:selector withObject:source];
		if(property != nil){
			[property setValue:result];
		}
		return result;
	}
		
	//Can extend here with string : exemple "@id[theid]" ou "@selector[@class:type,selectorname:]" ou "@selector[@id:theid,selectorname:params:]"
	
	//Use the default serialization for objects
	NSAssert([source isKindOfClass:[NSDictionary class]],@"object of type '%@' can only be set from dictionary",[type description]);
	
	id target = (property != nil) ? [property value] : nil;
	if(target == nil){
		Class typeToCreate = type;
		NSString* sourceClassName = [source objectForKey:CKSerializerClassTag];
		if(sourceClassName != nil){
			typeToCreate = NSClassFromString(sourceClassName);
		}
		target = [[[typeToCreate alloc]init]autorelease];
	}
	
	[NSValueTransformer transform:source toObject:target];
	if(property != nil){
		[property setValue:target];
	}
	return target;
}

+ (id)transform:(id)source toClass:(Class)type{
	return [NSValueTransformer transform:source toClass:type inProperty:nil];
}

+ (void)transform:(NSDictionary*)source toObject:(id)target{
	NSArray* descriptors = [target allPropertyDescriptors];
	for(CKClassPropertyDescriptor* descriptor in descriptors){
		id object = [source objectForKey:descriptor.name];
		if(object != nil){
			CKObjectProperty* property = [[CKObjectProperty alloc]initWithObject:target keyPath:descriptor.name];
			[NSValueTransformer transform:object inProperty:property];
			[property release];
		}
	}
}

+ (void)transform:(id)source toObject:(id)target usingMappings:(NSDictionary*)mappings{
	for(NSString* sourceKeyPath in [mappings allKeys]){
		NSString* targetKeyPath = [mappings objectForKey:sourceKeyPath];
		id sourceObject = [source valueForKeyPath:sourceKeyPath];
		CKObjectProperty* targetProperty = [CKObjectProperty propertyWithObject:target keyPath:targetKeyPath];
		[self transform:sourceObject inProperty:targetProperty];
	}
}

+ (NSInteger)parseString:(NSString*)str toEnum:(NSDictionary*)keyValues{
	NSInteger integer = 0;
	NSArray* components = [str componentsSeparatedByString:@"|"];
	for(NSString* c in components){
		NSInteger ci = [[keyValues objectForKey:[c stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]intValue];
		integer |= ci;
	}
	return integer;
}

+ (NSInteger)convertEnumFromObject:(id)object withEnumDefinition:(NSDictionary*)enumDefinition{
	if([object isKindOfClass:[NSString class]]){
		NSInteger result = [NSValueTransformer parseString:object toEnum:enumDefinition];
		return result;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for enum");
	return (object == nil) ? 0 : [object intValue];
}


+ (CGSize)parseStringToCGSize:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 2,@"invalid size format");
	return CGSizeMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}


+ (CGSize)convertCGSizeFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGSize size = [NSValueTransformer parseStringToCGSize:object];
		return size;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGSizeMake(10,10) : [object CGSizeValue];
}

+ (CGRect)parseStringToCGRect:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 4,@"invalid rect format");
	return CGRectMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue],[[components objectAtIndex:2]floatValue],[[components objectAtIndex:3]floatValue]);
}

+ (CGRect)convertCGRectFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGRect rect = [NSValueTransformer parseStringToCGRect:object];
		return rect;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGRectMake(0,0,10,10) : [object CGRectValue];
}

+ (CGPoint)parseStringToCGPoint:(NSString*)str{
	NSArray* components = [str componentsSeparatedByString:@" "];
	NSAssert([components count] == 2,@"invalid point format");
	return CGPointMake([[components objectAtIndex:0]floatValue],[[components objectAtIndex:1]floatValue]);
}

+ (CGPoint)convertCGPointFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		CGPoint point = [NSValueTransformer parseStringToCGPoint:object];
		return point;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSValue class]],@"invalid class for cgsize");
	return (object == nil) ? CGPointMake(10,10) : [object CGPointValue];
}

+ (char)convertCharFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		NSString* lower = [[object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
		if([lower isEqual:@"yes"] || [lower isEqual:@"true"] || [lower isEqual:@"1"]){
			return 1;
		}
		else if([lower isEqual:@"no"] || [lower isEqual:@"false"] || [lower isEqual:@"0"]){
			return 0;
		}
		return [object charValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for char");
	return (object == nil) ? ' ' : [object charValue];
}

+ (NSInteger)convertIntegerFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return [object intValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for int");
	return (object == nil) ? 0 : [object intValue];
}

+ (short)convertShortFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (short)[object intValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for short");
	return (object == nil) ? 0 : (short)[object intValue];
}

+ (long)convertLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (long)[object longLongValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for long");
	return (object == nil) ? 0 : (long)[object longValue];
}

+ (long long)convertLongLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (long long)[object longLongValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for long long");
	return (object == nil) ? 0 : (long long)[object longLongValue];
}

+ (unsigned char)convertUnsignedCharFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		NSString* lower = [[object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
		if([lower isEqual:@"yes"] || [lower isEqual:@"true"] || [lower isEqual:@"1"]){
			return 1;
		}
		else if([lower isEqual:@"no"] || [lower isEqual:@"false"] || [lower isEqual:@"0"]){
			return 0;
		}
		return (unsigned char)[object charValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned char");
	return (object == nil) ? ' ' : [object unsignedCharValue];
}

+ (NSUInteger)convertUnsignedIntFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (NSUInteger)[object intValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned int");
	return (object == nil) ? 0 : [object unsignedIntValue];
}

+ (unsigned short)convertUnsignedShortFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (unsigned short)[object intValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned short");
	return (object == nil) ? 0 : (unsigned short)[object intValue];
}

+ (unsigned long)convertUnsignedLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (unsigned long)[object longLongValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned long");
	return (object == nil) ? 0 : (unsigned long)[object longValue];
}

+ (unsigned long long)convertUnsignedLongLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (unsigned long long)[object longLongValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned long long");
	return (object == nil) ? 0 : (unsigned long long)[object longLongValue];
}

+ (CGFloat)convertFloatFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (CGFloat)[object floatValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for float");
	return (object == nil) ? 0.0f : (CGFloat)[object floatValue];
}

+ (double)convertDoubleFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (double)[object doubleValue];
	}
	
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for double");
	return (object == nil) ? 0.0 : (double)[object doubleValue];
}

+ (BOOL)convertBoolFromObject:(id)object{
	return [NSValueTransformer convertCharFromObject:object];
}

+ (Class)convertClassFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return NSClassFromString(object);
	}
	
	NSAssert(NO,@"invalid class for Class");
	return nil;
}

+ (SEL)convertSelectorFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return NSSelectorFromString(object);
	}
	
	NSAssert(NO,@"invalid class for selector");
	return nil;
}

@end


@implementation NSObject (CKTransformAdditions)

+ (SEL)convertFromObjectSelector:(id)object{
	Class sourceClass = [object class];
	while(sourceClass != nil){
		Class selfType = [self class];
		while(selfType != nil){
			NSString* selectorName = [NSString stringWithFormat:@"convertFrom%@:",[sourceClass description]];
			SEL selector = NSSelectorFromString(selectorName);
			if([selfType respondsToSelector:selector]){
				return selector;
			}
			selfType = class_getSuperclass(selfType);
		}
		sourceClass = class_getSuperclass(sourceClass);
	}
	return nil;
}

+ (SEL)convertToObjectSelector:(id)object{
	Class selfType = [self class];
	while(selfType != nil){
		Class sourceClass = [object class];
		while(sourceClass != nil){
			NSString* selectorName = [NSString stringWithFormat:@"convertTo%@:",[selfType description]];
			SEL selector = NSSelectorFromString(selectorName);
			if([sourceClass respondsToSelector:selector]){
				return selector;
			}
			sourceClass = class_getSuperclass(sourceClass);
		}
		selfType = class_getSuperclass(selfType);
	}
	return nil;
}

+ (SEL)valueTransformerObjectSelector:(id)object{
	Class ittype = [self class];
	while(ittype != nil){
		NSString* typeName = [ittype description];
		NSString* selectorName = [NSString stringWithFormat:@"convert%@FromObject:",typeName];
		SEL selector = NSSelectorFromString(selectorName);
		if([[NSValueTransformer class]respondsToSelector:selector]){
			return selector;
		}
		ittype = class_getSuperclass(ittype);
	}
	return nil;
}


+ (id)convertFromObject:(id)object{
	Class type = [self class];
	
	SEL selector = [type convertFromObjectSelector:object];
	if(selector != nil){
		id result = [type performSelector:selector withObject:object];
		return result;
	}
		
	selector = [type valueTransformerObjectSelector:object];
	if(selector != nil){
		id result = [[NSValueTransformer class] performSelector:selector withObject:object];
		return result;
	}
	
	return nil;
}

@end


@implementation UIColor (CKTransformAdditions)

+ (UIColor*)convertFromNSString:(NSString*)str{
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
			SEL colorSelector = NSSelectorFromString(str);
			if(colorSelector && [[UIColor class] respondsToSelector:colorSelector]){
				UIColor* color = [[UIColor class] performSelector:colorSelector];
				return color;
			}
			else{
				NSAssert(NO,@"invalid format for color");
			}
		}
	}
	
	return nil;
}

+ (UIColor*)convertFromNSNumber:(NSNumber*)n{
	UIColor* result = [UIColor colorWithRGBValue:[n intValue]];
	return result;
}

+ (NSString*)convertToNSString:(UIColor*)color{
	return [color description];
}

@end


@implementation UIImage (CKTransformAdditions)

+ (UIImage*)convertFromNSString:(NSString*)str{
	UIImage* image = [UIImage imageNamed:str];
	return image;
}

+ (UIImage*)convertFromNSURL:(NSURL*)url{
	if([url isFileURL]){
		UIImage* image = [UIImage imageWithContentsOfFile:[url path]];
		return image;
	}
	NSAssert(NO,@"Styles only supports file url yet");
	return nil;
}

+ (UIImage*)convertFromNSArray:(NSArray*)components{
	NSAssert([components count] == 2,@"invalid format for image");
	NSString* name = [components objectAtIndex:0];
	
	UIImage* image = [UIImage imageNamed:name];
	if(image){
		NSString* sizeStr = [components objectAtIndex:1];
		CGSize size = [NSValueTransformer parseStringToCGSize:sizeStr];
		image = [image stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
		return image;
	}
	return nil;
}

+ (NSString*)convertToNSString:(UIImage*)image{
	return [image description];
}

@end