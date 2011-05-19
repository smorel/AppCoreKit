//
//  CKSerializer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSValueTransformer+Additions.h"
#import <objc/runtime.h>

NSString* CKSerializerClassTag = @"@class";
NSString* CKSerializerIDTag = @"@id";

@interface NSValueTransformer()
+ (id)transform:(id)source toClass:(Class)type inProperty:(CKObjectProperty*)property;
@end

//utiliser des selector au lieu des valueTransformers
@implementation NSValueTransformer (CKAddition)

+ (void)transform:(id)object inProperty:(CKObjectProperty*)property{
	CKClassPropertyDescriptor* descriptor = [property descriptor];
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeChar:{
			char c = [NSValueTransformer charFromObject:object];
			[property setValue:[NSNumber numberWithChar:c]];
			break;
		}
		case CKClassPropertyDescriptorTypeInt:{
			NSInteger i = [NSValueTransformer integerFromObject:object];
			[property setValue:[NSNumber numberWithInt:i]];
			break;
		}
		case CKClassPropertyDescriptorTypeShort:{
			short s = [NSValueTransformer shortFromObject:object];
			[property setValue:[NSNumber numberWithShort:s]];
			break;
		}
		case CKClassPropertyDescriptorTypeLong:{
			long l = [NSValueTransformer longFromObject:object];
			[property setValue:[NSNumber numberWithLong:l]];
			break;
		}
		case CKClassPropertyDescriptorTypeLongLong:{
			long long ll = [NSValueTransformer longLongFromObject:object];
			[property setValue:[NSNumber numberWithLongLong:ll]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedChar:{
			unsigned char uc = [NSValueTransformer unsignedCharFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedChar:uc]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedInt:{
			NSUInteger ui = [NSValueTransformer unsignedIntFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedInt:ui]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedShort:{
			unsigned short us = [NSValueTransformer unsignedShortFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedShort:us]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedLong:{
			unsigned long ul = [NSValueTransformer unsignedLongFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedLong:ul]];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedLongLong:{
			unsigned long long ull = [NSValueTransformer unsignedLongLongFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedLongLong:ull]];
			break;
		}
		case CKClassPropertyDescriptorTypeFloat:{
			CGFloat f = [NSValueTransformer floatFromObject:object];
			[property setValue:[NSNumber numberWithFloat:f]];
			break;
		}
		case CKClassPropertyDescriptorTypeDouble:{
			double d = [NSValueTransformer doubleFromObject:object];
			[property setValue:[NSNumber numberWithDouble:d]];
			break;
		}
		case CKClassPropertyDescriptorTypeCppBool:{
			BOOL bo =  [NSValueTransformer boolFromObject:object];
			[property setValue:[NSNumber numberWithBool:bo]];
			break;
		}
		case CKClassPropertyDescriptorTypeClass:{
			Class c =  [NSValueTransformer classFromObject:object];
			[property setValue:c];
			break;
		}
		case CKClassPropertyDescriptorTypeSelector:{
			SEL s =  [NSValueTransformer selectorFromObject:object];
			[property setValue:[NSValue valueWithPointer:s]];
			break;
		}
		case CKClassPropertyDescriptorTypeObject:{
			[NSValueTransformer transform:object toClass:descriptor.type inProperty:property];
			break;
		}
		case CKClassPropertyDescriptorTypeStruct:{
			NSString* typeName = descriptor.className;
			NSString* selectorName = [NSString stringWithFormat:@"%@FromObject:",typeName];
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
	//Search for a specific transform selector
	Class ittype = type;
	while(ittype != nil){
		NSString* typeName = [ittype description];
		NSString* selectorName = [NSString stringWithFormat:@"%@FromObject:",typeName];
		SEL selector = NSSelectorFromString(selectorName);
		if([[NSValueTransformer class]respondsToSelector:selector]){
			id result = [[NSValueTransformer class] performSelector:selector withObject:source];
			if(property != nil){
				[property setValue:result];
			}
			return result;
		}
		ittype = class_getSuperclass(ittype);
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

+ (UIColor*)UIColorFromObject:(id)object{
	return nil;
}

+ (NSArray*)NSArrayFromObject:(id)object withContentClass:(Class)contentClass{
	return nil;
}

+ (NSSet*)NSSetFromObject:(id)object withContentClass:(Class)contentClass{
	return nil;
}

+ (UIImage*)UImageFromObject:(id)object{
	return nil;
}

+ (NSInteger)enumFromObject:(id)object withEnumDefinition:(NSDictionary*)enumDefinition{
	return 0;
}

+ (NSNumber*)NSNumberFormObject:(id)object{
	return nil;
}

+ (NSDate*)NSDateFromObject:(id)object withFormat:(NSString*)format{
	return nil;
}

+ (NSURL*)NSURLFromObject:(id)object{
	return nil;
}

+ (NSString*)NSStringFormObject:(id)object{
	return @"";
}

+ (CGSize)CGSizeFromObject:(id)object{
	return CGSizeMake(10,10);
}

+ (CGRect)CGRectFromObject:(id)object{
	return CGRectMake(10,10,10,10);
}

+ (CGPoint)CGPointFromObject:(id)object{
	return CGPointMake(10,10);
}

+ (char)charFromObject:(id)object{
	return 0;
}

+ (NSInteger)integerFromObject:(id)object{
	return 0;
}

+ (short)shortFromObject:(id)object{
	return 0;
}

+ (long)longFromObject:(id)object{
	return 0;
}

+ (long long)longLongFromObject:(id)object{
	return 0;
}

+ (unsigned char)unsignedCharFromObject:(id)object{
	return 0;
}

+ (NSUInteger)unsignedIntFromObject:(id)object{
	return 0;
}

+ (unsigned short)unsignedShortFromObject:(id)object{
	return 0;
}

+ (unsigned long)unsignedLongFromObject:(id)object{
	return 0;
}

+ (unsigned long long)unsignedLongLongFromObject:(id)object{
	return 0;
}

+ (CGFloat)floatFromObject:(id)object{
	return 0.0f;
}

+ (double)doubleFromObject:(id)object{
	return 0.0;
}

+ (BOOL)boolFromObject:(id)object{
	return NO;
}

+ (Class)classFromObject:(id)object{
	return nil;
}

+ (SEL)selectorFromObject:(id)object{
	return nil;
}

@end
