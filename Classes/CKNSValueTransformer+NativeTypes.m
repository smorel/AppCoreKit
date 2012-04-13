//
//  CKNSValueTransformer+NativeTypes.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSValueTransformer+NativeTypes.h"
#import "CKNSValueTransformer+Additions.h"

CKEnumDescriptor* CKEnumDefinitionFunc(NSString* name,BOOL bitMask,NSString* strValues, ...) {
	NSArray* components = [strValues componentsSeparatedByString:@","];
	
	va_list ArgumentList;
	va_start(ArgumentList,strValues);
	
	int i = 0;
	NSMutableDictionary* valuesAndLabels = [NSMutableDictionary dictionary];
	while (i < [components count]){
		int value = va_arg(ArgumentList, int);
            [valuesAndLabels setObject:[NSNumber numberWithInt:value] 
                     forKey:[[components objectAtIndex:i]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		++i;
    }
    va_end(ArgumentList);
	
    CKEnumDescriptor* descriptor = [[[CKEnumDescriptor alloc]init]autorelease];
    descriptor.name = name;
    descriptor.valuesAndLabels = valuesAndLabels;
    descriptor.isBitMask = bitMask;
	return descriptor;
}

@implementation CKEnumDescriptor
@synthesize name,valuesAndLabels,isBitMask;
-(void)dealloc{
    self.name = nil;
    self.valuesAndLabels = nil;
    [super dealloc];
}
@end

@implementation NSValueTransformer (CKNativeTypes)


+ (NSInteger)parseString:(NSString*)str toEnum:(CKEnumDescriptor*)descriptor bitMask:(BOOL)bitMask{
    if(bitMask){
        NSInteger integer = 0;
        NSArray* components = [str componentsSeparatedByString:@"|"];
        for(NSString* c in components){
            NSInteger ci = [[descriptor.valuesAndLabels objectForKey:[c stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]intValue];
            integer |= ci;
        }
        return integer;
    }
    
    NSNumber* ci = [descriptor.valuesAndLabels objectForKey:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if(ci){
        return [ci intValue];
    }
    return 0;
}

+ (NSInteger)convertEnumFromObject:(id)object withEnumDescriptor:(CKEnumDescriptor*)enumDefinition bitMask:(BOOL)bitMask{
	if([object isKindOfClass:[NSString class]]){
		NSInteger result = [NSValueTransformer parseString:object toEnum:enumDefinition bitMask:bitMask];
		return result;
	}
	NSAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for enum");
	return (object == nil) ? 0 : [object intValue];
}


+ (NSString*)convertEnumToString:(NSInteger)value withEnumDescriptor:(CKEnumDescriptor*)enumDefinition bitMask:(BOOL)bitMask{
	if(bitMask){
        NSMutableString* str = [NSMutableString string];
        for(NSString* e in [enumDefinition.valuesAndLabels allKeys]){
            NSInteger ci = [[enumDefinition.valuesAndLabels objectForKey:e]intValue];
            if(value & ci){
                if([str length] > 0){
                    [str appendString:@" | "];
                }
                [str appendString:e];
            }
        }
        return str;
    }
    
    for(NSString* e in [enumDefinition.valuesAndLabels allKeys]){
        NSInteger ci = [[enumDefinition.valuesAndLabels objectForKey:e]intValue];
        if(ci == value){
            return e;
        }
    }
    return @"";
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
