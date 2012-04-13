//
//  CKSerializer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSValueTransformer+Additions.h"
#import <objc/runtime.h>
#import "CKLocalization.h"

#import "CKObject+CKStore.h"

#define AUTO_LOCALIZATION 0


NSString* CKNSValueTransformerCacheClassTag = @"CKNSValueTransformerCacheClassTag";
NSString* CKNSValueTransformerCacheSelectorTag = @"CKNSValueTransformerCacheSelectorTag";

static NSMutableDictionary* CKNSValueTransformerCache = nil;
static NSMutableDictionary* CKNSValueTransformerIdentifierCache = nil;

NSString* CKSerializerClassTag = @"@class";
NSString* CKSerializerIDTag = @"@id";


@interface NSObject (CKValueTransformerSelectors)
+ (SEL)convertFromObjectSelector:(id)object;
+ (SEL)convertFromObjectWithContentClassNameSelector:(id)object;
+ (SEL)convertToObjectSelector:(id)object;
+ (SEL)valueTransformerObjectSelector:(id)object;
@end


@interface NSValueTransformer()
+ (id)transform:(id)source toClass:(Class)type inProperty:(CKProperty*)property;
+ (void)registerConverterWithIdentifier:(NSString*)identifier selectorClass:(Class)selectorClass selector:(SEL)selector;
+ (NSDictionary*)converterWithIdentifier:(NSString*)identifier;
+ (NSString*)identifierForSourceClass:(Class)source targetClass:(Class)class;
+ (NSString*)identifierForSourceClass:(Class)source targetClass:(Class)target contentClass:(Class)content;
@end

//utiliser des selector au lieu des valueTransformers
@implementation NSValueTransformer (CKAddition)

+ (id)transform:(id)object inProperty:(CKProperty*)property{
	CKClassPropertyDescriptor* descriptor = [property descriptor];
	
	switch(descriptor.propertyType){
		case CKClassPropertyDescriptorTypeChar:{
			char c = [NSValueTransformer convertCharFromObject:object];
			[property setValue:[NSNumber numberWithChar:c]];
			return [NSNumber numberWithChar:c];
			break;
		}
		case CKClassPropertyDescriptorTypeInt:{
			CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
			NSInteger i = 0;
			if(attributes.enumDescriptor != nil){
				i = [NSValueTransformer convertEnumFromObject:object withEnumDescriptor:attributes.enumDescriptor bitMask:attributes.enumDescriptor.isBitMask];
			}
			else{
				i = [NSValueTransformer convertIntegerFromObject:object];
			}
			[property setValue:[NSNumber numberWithInt:i]];
			return [NSNumber numberWithInt:i];
			break;
		}
		case CKClassPropertyDescriptorTypeShort:{
			short s = [NSValueTransformer convertShortFromObject:object];
			[property setValue:[NSNumber numberWithShort:s]];
			return [NSNumber numberWithShort:s];
			break;
		}
		case CKClassPropertyDescriptorTypeLong:{
			long l = [NSValueTransformer convertLongFromObject:object];
			[property setValue:[NSNumber numberWithLong:l]];
			return [NSNumber numberWithLong:l];
			break;
		}
		case CKClassPropertyDescriptorTypeLongLong:{
			long long ll = [NSValueTransformer convertLongLongFromObject:object];
			[property setValue:[NSNumber numberWithLongLong:ll]];
			return [NSNumber numberWithLongLong:ll];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedChar:{
			unsigned char uc = [NSValueTransformer convertUnsignedCharFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedChar:uc]];
			return [NSNumber numberWithUnsignedChar:uc];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedInt:{
			NSUInteger ui = [NSValueTransformer convertUnsignedIntFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedInt:ui]];
			return [NSNumber numberWithUnsignedInt:ui];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedShort:{
			unsigned short us = [NSValueTransformer convertUnsignedShortFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedShort:us]];
			return [NSNumber numberWithUnsignedShort:us];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedLong:{
			unsigned long ul = [NSValueTransformer convertUnsignedLongFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedLong:ul]];
			return [NSNumber numberWithUnsignedLong:ul];
			break;
		}
		case CKClassPropertyDescriptorTypeUnsignedLongLong:{
			unsigned long long ull = [NSValueTransformer convertUnsignedLongLongFromObject:object];
			[property setValue:[NSNumber numberWithUnsignedLongLong:ull]];
			return [NSNumber numberWithUnsignedLongLong:ull];
			break;
		}
		case CKClassPropertyDescriptorTypeFloat:{
			CGFloat f = [NSValueTransformer convertFloatFromObject:object];
			[property setValue:[NSNumber numberWithFloat:f]];
			return [NSNumber numberWithFloat:f];
			break;
		}
		case CKClassPropertyDescriptorTypeDouble:{
			double d = [NSValueTransformer convertDoubleFromObject:object];
			[property setValue:[NSNumber numberWithDouble:d]];
			return [NSNumber numberWithDouble:d];
			break;
		}
		case CKClassPropertyDescriptorTypeCppBool:{
			BOOL bo =  [NSValueTransformer convertBoolFromObject:object];
			[property setValue:[NSNumber numberWithBool:bo]];
			return [NSNumber numberWithBool:bo];
			break;
		}
		case CKClassPropertyDescriptorTypeClass:{
			Class c =  [NSValueTransformer convertClassFromObject:object];
            [property setValue:(id)c];
			/*[property setValue:[NSValue valueWithPointer:c]];
			return [NSValue valueWithPointer:c];*/
            return c;
			break;
		}
		case CKClassPropertyDescriptorTypeSelector:{
			SEL s =  [NSValueTransformer convertSelectorFromObject:object];
			[property setValue:[NSValue valueWithPointer:s]];
			return [NSValue valueWithPointer:s];
			break;
		}
		case CKClassPropertyDescriptorTypeObject:{
			id result = [NSValueTransformer transform:object toClass:descriptor.type inProperty:property];
			return result;
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
                
                free(returnValue);
                
				return value;
			}
			else{
				NSAssert(NO,@"No transform selector for struct of type '%@'",typeName);
			}
			break;
		}
        case CKClassPropertyDescriptorTypeStructPointer:{
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
				
				void* returnValue = nil;
				[invocation getReturnValue:&returnValue];
				
				//NSValue* value =  [NSValue valueWithPointer:returnValue];
				[property setValue:(id)returnValue];
				return (id)returnValue;
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
	return nil;
}


+ (void)registerConverterWithIdentifier:(NSString*)identifier selectorClass:(Class)selectorClass selector:(SEL)selector{
	if(CKNSValueTransformerCache == nil){
		CKNSValueTransformerCache = [[NSMutableDictionary dictionary]retain];
	}
	[CKNSValueTransformerCache setValue:[NSDictionary dictionaryWithObjectsAndKeys:
										 [NSValue valueWithPointer:selectorClass],CKNSValueTransformerCacheClassTag,
										 [NSValue valueWithPointer:selector],CKNSValueTransformerCacheSelectorTag,nil]
								 forKey:identifier];
}

+ (NSDictionary*)converterWithIdentifier:(NSString*)identifier{
	return [CKNSValueTransformerCache objectForKey:identifier];
}

+ (NSString*)identifierForSourceClass:(Class)source targetClass:(Class)target{
	NSDictionary* dico = [CKNSValueTransformerIdentifierCache objectForKey:[source description]];
	if(dico != nil){
		id value = [dico objectForKey:[target description]];
		if([value isKindOfClass:[NSString class]])
			return value;
	}
	
	NSString* converterIdentifier = [NSString stringWithFormat:@"%@TO%@",[[source class]description],[target description]];
	if(CKNSValueTransformerIdentifierCache == nil){
		CKNSValueTransformerIdentifierCache = [[NSMutableDictionary dictionary]retain];
		[CKNSValueTransformerIdentifierCache setObject:[NSMutableDictionary dictionaryWithObject:converterIdentifier 
																		 forKey:[target description]]
									  forKey:[source description]];
	}
	else{
		NSMutableDictionary* dico = [CKNSValueTransformerIdentifierCache objectForKey:[source description]];
		if(dico == nil){
			[CKNSValueTransformerIdentifierCache setObject:[NSMutableDictionary dictionaryWithObject:converterIdentifier 
																					   forKey:[target description]]
													forKey:[source description]];
		}
		else{
			[dico setObject:converterIdentifier forKey:[target description]];
		}
	}
	return converterIdentifier;
}

+ (NSString*)identifierForSourceClass:(Class)source targetClass:(Class)target contentClass:(Class)content{
	NSString* converterIdentifier = [NSString stringWithFormat:@"%@_%@TO%@",[[source class]description],[content description],[target description]];
	return converterIdentifier;
}

+ (id)transform:(id)source toClass:(Class)type inProperty:(CKProperty*)property{
	if(source == nil){
		if(property != nil){
			[property setValue:nil];
		}
		return nil;
	}
	
	//Can extend here with string : exemple "@id[theid]" ou "@selector[@class:type,selectorname:]" ou "@selector[@id:theid,selectorname:params:]"
	
	CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
	if(attributes.contentType != nil){
		NSString* converterIdentifier = [NSValueTransformer identifierForSourceClass:[source class] targetClass:type contentClass:attributes.contentType];
		NSDictionary* dico = [NSValueTransformer converterWithIdentifier:converterIdentifier];
		
		SEL selector = nil;
		if(dico != nil){
			selector = [[dico objectForKey:CKNSValueTransformerCacheSelectorTag]pointerValue];
		}
		
		if(selector == nil){
			selector = [type convertFromObjectWithContentClassNameSelector:source];
			[NSValueTransformer registerConverterWithIdentifier:converterIdentifier selectorClass:type selector:selector];
		}
		
		if(selector != nil){
			id result = [type performSelector:selector withObject:source withObject:[attributes.contentType description]];
			if(AUTO_LOCALIZATION && [result isKindOfClass:[NSString class]]){
				result = _(result);
			}
			
			if(property != nil){
				[property setValue:result];
			}
			return result;
		}
	}
	
	//special case for date
	if(attributes.dateFormat != nil && [NSObject isClass:type kindOfClass:[NSDate class]]
	   && [source isKindOfClass:[NSString class]]){
		id result = [NSDate convertFromNSString:source withFormat:attributes.dateFormat];
		if(property != nil){
			[property setValue:result];
		}
		return source;
	}
	else if(attributes.dateFormat != nil && [NSObject isClass:type kindOfClass:[NSString class]]
			&& [source isKindOfClass:[NSDate class]]){
		id result = [NSDate convertToNSString:source withFormat:attributes.dateFormat];
		if(property != nil){
			[property setValue:result];
		}
		return source;
	}
	
	//if no conversion requiered, set the property directly
	if([source isKindOfClass:type]){
		id result = source;
		if(AUTO_LOCALIZATION && [result isKindOfClass:[NSString class]]){
			result = _(result);
		}
		if(property != nil){
			[property setValue:result];
		}
		return result;
	}
	
	//Use the cached selector if exists
	NSString* converterIdentifier = [NSValueTransformer identifierForSourceClass:[source class] targetClass:type];
	NSDictionary* dico = [NSValueTransformer converterWithIdentifier:converterIdentifier];
	if(dico != nil){
		SEL selector = [[dico objectForKey:CKNSValueTransformerCacheSelectorTag]pointerValue];
		if(selector != nil){
			Class selectorClass = [[dico objectForKey:CKNSValueTransformerCacheClassTag]pointerValue];
			id result = [selectorClass performSelector:selector withObject:source];
			if(AUTO_LOCALIZATION && [result isKindOfClass:[NSString class]]){
				result = _(result);
			}			
			if(property != nil){
				[property setValue:result];
			}
			return result;
		}
	}
	
	SEL selector = [type convertFromObjectSelector:source];
	if(selector != nil){
		[NSValueTransformer registerConverterWithIdentifier:converterIdentifier selectorClass:type selector:selector];
		id result = [type performSelector:selector withObject:source];
		if(AUTO_LOCALIZATION && [result isKindOfClass:[NSString class]]){
			result = _(result);
		}	
		if(property != nil){
			[property setValue:result];
		}
		return result;
	}
	
	selector = [type convertToObjectSelector:source];
	if(selector != nil){
		[NSValueTransformer registerConverterWithIdentifier:converterIdentifier selectorClass:[source class] selector:selector];
		id result = [[source class] performSelector:selector withObject:source];
		if(AUTO_LOCALIZATION && [result isKindOfClass:[NSString class]]){
			result = _(result);
		}	
		if(property != nil){
			[property setValue:result];
		}
		return result;
	}
	
	selector = [type valueTransformerObjectSelector:source];
	if(selector != nil){
		[NSValueTransformer registerConverterWithIdentifier:converterIdentifier selectorClass:[NSValueTransformer class] selector:selector];
		id result = [[NSValueTransformer class] performSelector:selector withObject:source];
		if(AUTO_LOCALIZATION && [result isKindOfClass:[NSString class]]){
			result = _(result);
		}	
		if(property != nil){
			[property setValue:result];
		}
		return result;
	}
	
    
	id target = (property != nil) ? [property value] : nil;
	//Use the default serialization for objects
	NSAssert([source isKindOfClass:[NSDictionary class]],@"object of type '%@' can only be set from dictionary",[type description]);
	if(target == nil){
		Class typeToCreate = type;
		NSString* sourceClassName = [source objectForKey:CKSerializerClassTag];
		if(sourceClassName != nil){
			typeToCreate = NSClassFromString(sourceClassName);
		}
		
        
		if([NSObject isClass:typeToCreate kindOfClass:[CKObject class]]){
			id uniqueId = [source valueForKeyPath:@"uniqueId"];
			if([uniqueId isKindOfClass:[NSString class]]){
				target = [CKObject objectWithUniqueId:uniqueId];
			}
			if(target == nil){
				target = [[[typeToCreate alloc]init]autorelease];
				[CKObject registerObject:target withUniqueId:uniqueId];
			}
		}
		else{
			target = [[[typeToCreate alloc]init]autorelease];
		}
	}
	
	[NSValueTransformer transform:source toObject:target];
	if(property != nil){
		[property setValue:target];
	}
	return target;
}

+ (id)transform:(id)source toClass:(Class)type{
	id result = [NSValueTransformer transform:source toClass:type inProperty:nil];
	if(AUTO_LOCALIZATION && [result isKindOfClass:[NSString class]]){
		return _(result);
	}
	return result;
}


+ (id)transformProperty:(CKProperty*)property toClass:(Class)type{
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
	if([NSObject isClass:type kindOfClass:[NSString class]]
	   && [[property value]isKindOfClass:[NSNumber class]]){
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		switch(descriptor.propertyType){
			case CKClassPropertyDescriptorTypeInt:{
				if(attributes.enumDescriptor != nil){
					return [NSValueTransformer convertEnumToString:[[property value]intValue] withEnumDescriptor:attributes.enumDescriptor bitMask:attributes.enumDescriptor.isBitMask];
				}
				break;
			}
		}
	}
	//special case for date ...
    else if(attributes.dateFormat != nil && [NSObject isClass:type kindOfClass:[NSDate class]]
	   && [property.value isKindOfClass:[NSString class]]){
		id result = [NSDate convertFromNSString:property.value withFormat:attributes.dateFormat];
		return result;
	}
	else if(attributes.dateFormat != nil && [NSObject isClass:type kindOfClass:[NSString class]]
			&& [property.value isKindOfClass:[NSDate class]]){
		id result = [NSDate convertToNSString:property.value withFormat:attributes.dateFormat];
		return result;
	}
    
	return [NSValueTransformer transform:[property value] toClass:type];
}

+ (void)transform:(NSDictionary*)source toObject:(id)target{
	if([target isKindOfClass:[CKObject class]]){
		CKObject* model = (CKObject*)target;
		[model performSelector:@selector(setLoading:) withObject:[NSNumber numberWithBool:YES]];//PRIVATE SELECTOR
	}
	NSArray* descriptors = [target allPropertyDescriptors];
	for(CKClassPropertyDescriptor* descriptor in descriptors){
		id object = [source objectForKey:descriptor.name];
		if(object != nil){
			CKProperty* property = [[CKProperty alloc]initWithObject:target keyPath:descriptor.name];
			[NSValueTransformer transform:object inProperty:property];
			[property autorelease];
		}
	}
	if([target isKindOfClass:[CKObject class]]){
		CKObject* model = (CKObject*)target;
		[model performSelector:@selector(setLoading:) withObject:[NSNumber numberWithBool:NO]];//PRIVATE SELECTOR
	}
}

@end



@implementation NSObject (CKValueTransformerSelectors)

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

+ (SEL)convertFromObjectWithContentClassNameSelector:(id)object{
	Class sourceClass = [object class];
	while(sourceClass != nil){
		Class selfType = [self class];
		while(selfType != nil){
			NSString* selectorName = [NSString stringWithFormat:@"convertFrom%@:withContentClassName:",[sourceClass description]];
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

@end


