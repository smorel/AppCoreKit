//
//  NSArray+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSArray+ValueTransformer.h"
#import "NSObject+ValueTransformer.h"
#import "NSValueTransformer+Additions.h"

#import "CKDebug.h"

@implementation NSArray (CKValueTransformer)

+ (NSArray*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className{
	NSMutableArray* results = [NSMutableArray array];
	Class type = NSClassFromString(className);
	for(id content in array){
		if(type != nil){
			id result = [NSValueTransformer transform:content toClass:type];
			[results addObject:result];
		}
		else{
            NSString* selectorName = [NSString stringWithFormat:@"convert%@FromObject:",className];
            SEL selector = NSSelectorFromString(selectorName);
            if([[NSValueTransformer class]respondsToSelector:selector]){
                //nsinvokation
                id result = [NSValueTransformer performSelector:selector withObject:content];
                [results addObject:result];
            }
            else{
                CKAssert(NO,@"no convertion function found");
            }
		}
	}
	return results;
}


+ (id)convertFromNSArray:(NSArray*)components{
    NSMutableArray* results = [NSMutableArray array];
    for(id content in components){
        if([content isKindOfClass:[NSDictionary class]]){
            NSString* sourceClassName = [[content objectForKey:@"@class"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if(sourceClassName != nil){
                Class typeToCreate = NSClassFromString(sourceClassName);
				if(!typeToCreate){
				    NSLog(@"NSArray Conversion: Could not find class with name '%@'. The creation of the object will be bypassed in array with content:\n%@",sourceClassName,components);
				}else{
					id result = [NSValueTransformer transform:content toClass:typeToCreate];
					if(result == nil){
					    int i = 3;
					}
					[results addObject:result];
				}

            }
            else{
                CKAssert(NO,@"No @class defined in %@. cannot resolve the type automatically. Please define @class in the dictionary or specify contentType in the attributes",content);
            }
        }
        else{
            [results addObject:content];
        }
    }
    return results;
}


+ (id)convertFromNSDictionary:(NSDictionary*)dictionary{
    NSMutableArray* results = [NSMutableArray array];
    id object = [NSObject objectFromDictionary:dictionary];
    [results addObject:object];
    return results;
}

+ (id)objectArrayFromDictionaryArray:(NSArray*)array{
	NSMutableArray* results = [NSMutableArray array];
	for(id o in array){
		CKAssert([o isKindOfClass:[NSDictionary class]],@"invalid object type in array");
		id object = [NSObject objectFromDictionary:o];
		if(object){
			[results addObject:object];
		}
	}
	return results;
}

@end


@implementation NSSet (CKValueTransformer)

+ (NSSet*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className{
    NSArray* c = [NSArray convertFromNSArray:array withContentClassName:className];
    return [[self class]setWithArray:c];
}

+ (id)convertFromNSArray:(NSArray*)array{
    NSArray* c = [NSArray convertFromNSArray:array];
    return [[self class]setWithArray:c];
}


@end