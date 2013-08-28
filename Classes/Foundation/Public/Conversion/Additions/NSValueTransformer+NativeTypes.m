//
//  NSValueTransformer+NativeTypes.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSValueTransformer+NativeTypes.h"
#import "NSValueTransformer+Additions.h"

#import "CKDebug.h"

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
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for enum");
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
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for char");
	return (object == nil) ? ' ' : [object charValue];
}

+ (NSInteger)convertIntegerFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return [object intValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for int");
	return (object == nil) ? 0 : [object intValue];
}

+ (short)convertShortFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (short)[object intValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for short");
	return (object == nil) ? 0 : (short)[object intValue];
}

+ (long)convertLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (long)[object longLongValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for long");
	return (object == nil) ? 0 : (long)[object longValue];
}

+ (long long)convertLongLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (long long)[object longLongValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for long long");
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
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned char");
	return (object == nil) ? ' ' : [object unsignedCharValue];
}

+ (NSUInteger)convertUnsignedIntFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (NSUInteger)[object intValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned int");
	return (object == nil) ? 0 : [object unsignedIntValue];
}

+ (unsigned short)convertUnsignedShortFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (unsigned short)[object intValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned short");
	return (object == nil) ? 0 : (unsigned short)[object intValue];
}

+ (unsigned long)convertUnsignedLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (unsigned long)[object longLongValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned long");
	return (object == nil) ? 0 : (unsigned long)[object longValue];
}

+ (unsigned long long)convertUnsignedLongLongFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (unsigned long long)[object longLongValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for unsigned long long");
	return (object == nil) ? 0 : (unsigned long long)[object longLongValue];
}

+ (CGFloat)convertFloatFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (CGFloat)[object floatValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for float");
	return (object == nil) ? 0.0f : (CGFloat)[object floatValue];
}

+ (double)convertDoubleFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return (double)[object doubleValue];
	}
	
	CKAssert(object == nil || [object isKindOfClass:[NSNumber class]],@"invalid class for double");
	return (object == nil) ? 0.0 : (double)[object doubleValue];
}

+ (BOOL)convertBoolFromObject:(id)object{
	return [NSValueTransformer convertCharFromObject:object];
}

+ (Class)convertClassFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return NSClassFromString(object);
	}
	
	CKAssert(NO,@"invalid class for Class");
	return nil;
}

+ (SEL)convertSelectorFromObject:(id)object{
	if([object isKindOfClass:[NSString class]]){
		return NSSelectorFromString(object);
	}
	
	CKAssert(NO,@"invalid class for selector");
	return nil;
}


@end
