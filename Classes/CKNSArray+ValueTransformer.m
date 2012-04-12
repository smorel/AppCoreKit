//
//  CKNSArray+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSArray+ValueTransformer.h"
#import "CKNSObject+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"


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
                NSAssert(NO,@"no convertion function found");
            }
		}
	}
	return results;
}


+ (id)convertFromNSArray:(NSArray*)components{
    NSMutableArray* results = [NSMutableArray array];
    for(id content in components){
        if([content isKindOfClass:[NSDictionary class]]){
            NSString* sourceClassName = [content objectForKey:@"@class"];
            if(sourceClassName != nil){
                Class typeToCreate = NSClassFromString(sourceClassName);
                id result = [NSValueTransformer transform:content toClass:typeToCreate];
                [results addObject:result];
            }
            else{
                NSAssert(NO,@"No @class defined in %@. cannot resolve the type automatically. Please define @class in the dictionary or specify contentType in the attributes",content);
            }
        }
        else{
            [results addObject:content];
        }
    }
    return results;
}

+ (id)objectArrayFromDictionaryArray:(NSArray*)array{
	NSMutableArray* results = [NSMutableArray array];
	for(id o in array){
		NSAssert([o isKindOfClass:[NSDictionary class]],@"invalid object type in array");
		id object = [NSObject objectFromDictionary:o];
		if(object){
			[results addObject:object];
		}
	}
	return results;
}

@end
