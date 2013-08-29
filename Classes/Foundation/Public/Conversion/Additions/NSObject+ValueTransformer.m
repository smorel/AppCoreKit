//
//  NSObject+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "NSObject+ValueTransformer.h"
//#import "CKObject+CKStore_Private.h"
#import "NSValueTransformer+Additions.h"
//#import "CKObject+CKStore.h"

#import "CKDebug.h"

//Implemented in NSValueTransformer+Additions.m
@interface NSObject (CKValueTransformerSelectors)
+ (SEL)convertFromObjectSelector:(id)object;
+ (SEL)convertFromObjectWithContentClassNameSelector:(id)object;
+ (SEL)convertToObjectSelector:(id)object;
+ (SEL)valueTransformerObjectSelector:(id)object;
@end

@implementation NSObject (CKValueTransformer)

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


+ (id)objectFromDictionary:(NSDictionary*)dictionary{
	Class typeToCreate = nil;
	NSString* sourceClassName = [dictionary objectForKey:@"@class"];
	if(sourceClassName != nil){
		typeToCreate = NSClassFromString(sourceClassName);
	}
	
	if(typeToCreate == nil){
		return nil;
	}
	
	id returnObject = nil;
	if([NSObject isClass:typeToCreate kindOfClass:[CKObject class]]){
		id uniqueId = [dictionary valueForKeyPath:@"uniqueId"];
		if([uniqueId isKindOfClass:[NSString class]]){
            //CKStore Extension Weak Compatibility
            if([CKObject respondsToSelector:@selector(objectWithUniqueId:)] ){
                returnObject = [CKObject performSelector:@selector(objectWithUniqueId:) withObject:uniqueId];
            }
		}
		if(returnObject == nil){
			returnObject = [[[typeToCreate alloc]init]autorelease];
            
            //CKStore Extension Weak Compatibility
            if([CKObject respondsToSelector:@selector(registerObject:withUniqueId:)] ){
                [CKObject performSelector:@selector(registerObject:withUniqueId:) withObject:returnObject withObject:uniqueId];
            }
		}
	}
	else{
		returnObject = [[[typeToCreate alloc]init]autorelease];
	}
	
	[NSValueTransformer transform:dictionary toObject:returnObject];
	return returnObject;
}

+ (id)convertFromNSArray:(NSArray*)array{
	if([array count] == 0){
		return nil;
	}
	else if([array count] == 1){
        id object = [array objectAtIndex:0];
        if([object isKindOfClass:[NSDictionary class]]){
            return [NSObject objectFromDictionary:object];
        }
        return object;
	}
	else{
		CKAssert(NO,@"too much elements in array");
	}
	return (id)nil;
}

+ (NSString*)convertToNSString:(id)object{
    if(!object){
        return @"nil";
    }
    return [NSString stringWithFormat:@"%@ : <%p>",object,[object class]];
}

@end
