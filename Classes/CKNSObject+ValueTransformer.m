//
//  CKNSObject+ValueTransformer.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNSObject+ValueTransformer.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObject+CKStore.h"

//Implemented in CKNSValueTransformer+Additions.m
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
	if([NSObject isKindOf:typeToCreate parentType:[CKObject class]]){
		id uniqueId = [dictionary valueForKeyPath:@"uniqueId"];
		if([uniqueId isKindOfClass:[NSString class]]){
			returnObject = [CKObject objectWithUniqueId:uniqueId];
		}
		if(returnObject == nil){
			returnObject = [[[typeToCreate alloc]init]autorelease];
			[CKObject registerObject:returnObject withUniqueId:uniqueId];
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
		return [NSObject objectFromDictionary:[array objectAtIndex:0]];
	}
	else{
		NSAssert(NO,@"too much elements in array");
	}
	return (id)nil;
}

+ (NSString*)convertToNSString:(id)object{
    return [NSString stringWithFormat:@"%@ : <%p>",object,[object class]];
}

@end
