//
//  NFBObject.m
//  NFB
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"
#import <objc/runtime.h>

@implementation CKModelObject

- (void)dealloc{
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		if(object && property.isObject){
			[object release];
		}
	}];
	[super dealloc];
}

- (NSString*)description{
	NSMutableString* desc = [NSMutableString stringWithFormat:@"%@ : <%p> {\n",[self className],self];
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		NSString* propertyString = [NSString stringWithFormat:@"%@ = %@\n",property.name,[object description]];
		[desc appendString:propertyString];
	}];
	[desc appendString:@"}"];
	 
	return desc;
}

- (id) copyWithZone:(NSZone *)zone {
	id copied = [[[self class] alloc] init];
	
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		[copied setValue:[self valueForKey:property.name] forKey:property.name];
	}];
	
	return copied;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	NSAssert([aDecoder allowsKeyedCoding],@"NFBModelObject does not support sequential archiving.");
    self = [super init];
    if (self) {
		[self executeForAllProperties:^(CKObjectProperty* property,id object){
			if([aDecoder containsValueForKey:property.name]){
				[self setValue:[aDecoder decodeObjectForKey:property.name] forKey:property.name];
			}else{
				NSLog(@"property %@ not found in archive for object of type %@\nDo migration if needed.",property.name,[self className]);
			}
		}];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	NSAssert([aCoder allowsKeyedCoding],@"NFBModelObject does not support sequential archiving.");
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		[aCoder encodeObject:object forKey:property.name];
	}];
}

- (BOOL) isEqual:(id)other {
	if ([other isKindOfClass:[self class]]) {
		__block BOOL result = YES;
		[self executeForAllProperties:^(CKObjectProperty* property,id object){
			id otherObject = [other valueForKey:property.name];
			BOOL propertyEqual = ((object == nil && otherObject == nil) || [object isEqual:otherObject]);;
			if(!propertyEqual){
				result = NO;
			}
		}];
		return result;
	}
	return NO;
}

- (NSUInteger)hash {
	NSMutableArray* allValues = [NSMutableArray array];
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		[allValues addObject:object];
	}];
	return (NSUInteger)[allValues hash];
}

- (void)executeForAllProperties:(CKModelObjectBlock)block{
	NSArray* allProperties = [self allProperties];
	for(CKObjectProperty* property in allProperties){
		id obj = [self valueForKey:property.name];
		block(property,obj);
	}
}

@end
