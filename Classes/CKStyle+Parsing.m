//
//  CKStyle+Parsing.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyle+Parsing.h"
#import "UIColor+Additions.h"
#import "CKLocalization.h"


#import "UIColor+ValueTransformer.h"
#import "UIImage+ValueTransformer.h"
#import "NSNumber+ValueTransformer.h"
#import "NSURL+ValueTransformer.h"
#import "NSDate+ValueTransformer.h"
#import "NSArray+ValueTransformer.h"
#import "CKCollection+ValueTransformer.h"
#import "NSIndexPath+ValueTransformer.h"
#import "NSObject+ValueTransformer.h"
#import "NSValueTransformer+NativeTypes.h"
#import "NSValueTransformer+CGTypes.h"
#import "CKConfiguration.h"

#import "CKDebug.h"

//TODO : HERE store the converted data in the key to convert only once !

static NSSet* CKStyleResourceTypeSet = nil;

@implementation NSMutableDictionary (CKStyleParsing)

- (UIColor*) colorForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return nil;
	if([object isKindOfClass:[UIColor class]]){
		return object;
	}
	id result = [NSValueTransformer transform:object toClass:[UIColor class]];
	if(result){
		[self setObject:result forKey:key];
	}
	return result;
}

- (NSArray*) colorArrayForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return nil;
	id result = [NSArray convertFromNSArray:object withContentClassName:@"UIColor"];
	if(result){
		[self setObject:result forKey:key];
	}
	return result;
}

- (NSArray*) cgFloatArrayForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return nil;
	id result = [NSArray convertFromNSArray:object withContentClassName:@"NSNumber"];
	if(result){
		[self setObject:result forKey:key];
	}
	return result;
}

- (UIImage*) imageForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return nil;
	if([object isKindOfClass:[UIImage class]]){
		return object;
	}
	id result = [NSValueTransformer transform:object toClass:[UIImage class]];
    if(![[CKConfiguration sharedInstance]resourcesLiveUpdateEnabled]){
        if(result){
            [self setObject:result forKey:key];
        }
    }
    return result;
}

- (NSInteger) enumValueForKey:(NSString*)key withEnumDescriptor:(CKEnumDescriptor*)enumDescriptor{
	id object = [self objectForKey:key];
    if(!object) return 0;
	if([object isKindOfClass:[NSNumber class]]){
		return [object intValue];
	}
	NSInteger result = [NSValueTransformer convertEnumFromObject:object withEnumDescriptor:enumDescriptor bitMask:enumDescriptor.isBitMask];
	[self setObject:[NSNumber numberWithInt:result] forKey:key];
	return result;
}

- (NSInteger) bitMaskValueForKey:(NSString*)key withEnumDescriptor:(CKEnumDescriptor*)enumDescriptor{
	id object = [self objectForKey:key];
    if(!object) return 0;
	if([object isKindOfClass:[NSNumber class]]){
		return [object intValue];
	}
	NSInteger result = [NSValueTransformer convertEnumFromObject:object withEnumDescriptor:enumDescriptor bitMask:YES];
	[self setObject:[NSNumber numberWithInt:result] forKey:key];
	return result;
}

- (CGSize) cgSizeForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return CGSizeMake(0,0);
	if([object isKindOfClass:[NSValue class]]){
		return [object CGSizeValue];
	}
	CGSize result = [NSValueTransformer convertCGSizeFromObject:object];
	[self setObject:[NSValue valueWithCGSize:result] forKey:key];
	return result;	
}

- (CGFloat) cgFloatForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return 0;
	if([object isKindOfClass:[NSNumber class]]){
		return [object floatValue];
	}
	CGFloat result = [NSValueTransformer convertFloatFromObject:object];
	[self setObject:[NSNumber numberWithFloat:result] forKey:key];
	return result;	
}


- (NSString*) stringForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return nil;
	CKAssert(object == nil || [object isKindOfClass:[NSString class]],@"invalid class for string");
	return _((NSString*)object);
}

- (NSInteger) integerForKey:(NSString*)key{
	id object = [self objectForKey:key];
    if(!object) return 0;
	if([object isKindOfClass:[NSNumber class]]){
		return [object intValue];
	}
	NSInteger result = [NSValueTransformer convertIntegerFromObject:object];
	[self setObject:[NSNumber numberWithInt:result] forKey:key];
	return result;	
}

- (BOOL) boolForKey:(NSString*)key{
    id object = [self objectForKey:key];
    if(!object) return 0;
	if([object isKindOfClass:[NSNumber class]]){
		return [object boolValue];
	}
	BOOL result = [NSValueTransformer convertBoolFromObject:object];
	[self setObject:[NSNumber numberWithBool:result] forKey:key];
	return result;
}

+ (NSSet*)resourceTypes{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKStyleResourceTypeSet = [[NSSet setWithObjects:
                                   [NSValue valueWithPointer:[NSString class]],
                                   [NSValue valueWithPointer:[NSURL class]],
                                   [NSValue valueWithPointer:[UIColor class]],
                                   [NSValue valueWithPointer:[UIImage class]],
                                   [NSValue valueWithPointer:[NSNumber class]],
                                   [NSValue valueWithPointer:[NSValue class]],
                                   [NSValue valueWithPointer:[NSDate class]],
                                   [NSValue valueWithPointer:[NSIndexPath class]],
                                   nil]retain];
    });
    return CKStyleResourceTypeSet;
}

- (id)setObjectForKey:(NSString*)key inProperty:(CKProperty*)property{
	id object = [self objectForKey:key];
	id transformedValue = [NSValueTransformer transform:object inProperty:property];
    if(object == transformedValue){
        return transformedValue;
    }
    
    //Force localization
	if([transformedValue isKindOfClass:[NSString class]]){
		transformedValue = _((NSString*)transformedValue);
		[property setValue:transformedValue];
	}
    
    //Cache resources in style tree to avoid parsing each time
    NSSet* theResourceTypes = [NSMutableDictionary resourceTypes];
	if(transformedValue != nil && [theResourceTypes containsObject:[NSValue valueWithPointer:[transformedValue class]]]){
		[self setObject:transformedValue forKey:key];
	}
	return transformedValue;	
}

@end