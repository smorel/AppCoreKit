//
//  NFBObject.m
//  NFB
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"
#import <objc/runtime.h>

static CKModelObjectPropertyMetaData* CKModelObjectPropertyMetaDataSingleton = nil;

@implementation CKModelObjectPropertyMetaData
@synthesize comparable;
@synthesize serializable;
@synthesize creatable;
@synthesize hashable;
@synthesize copiable;

- (void)reset{
	comparable = YES;
	serializable = YES;
	creatable = YES;
	hashable = NO;
	copiable = YES;
}

+ (CKModelObjectPropertyMetaData*)propertyMetaDataForObject:(id)object property:(CKObjectProperty*)property{
	if(CKModelObjectPropertyMetaDataSingleton == nil){
		CKModelObjectPropertyMetaDataSingleton = [[CKModelObjectPropertyMetaData alloc]init];
	}
	[CKModelObjectPropertyMetaDataSingleton reset];
	
	SEL metaDataSelector = property.metaDataSelector;
	if([object respondsToSelector:metaDataSelector]){
		[object performSelector:metaDataSelector withObject:CKModelObjectPropertyMetaDataSingleton];
	}
	
	return CKModelObjectPropertyMetaDataSingleton;
}

@end

static NSString* CKModelObjectAllPropertyNamesKey = @"CKModelObjectAllPropertyNamesKey";

@implementation CKModelObject

- (id)init{
	[super init];
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		if(property.isObject){
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
			if(metaData.creatable){
				id p = [[[property.type alloc]init]autorelease];
				[self setValue:p forKey:property.name];
			}
		}
	}];
	return self;
}

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
		CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
		if(metaData.copiable){
			[copied setValue:[self valueForKey:property.name] forKey:property.name];
		}
	}];
	
	return copied;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	NSAssert([aDecoder allowsKeyedCoding],@"NFBModelObject does not support sequential archiving.");
    self = [super init];
    if (self) {
		//FUCK names est mal serialize !!!!!!!!!
		NSArray* names = [aDecoder decodeObjectForKey:CKModelObjectAllPropertyNamesKey];
		NSMutableArray* allPropertiesInDecoder = [NSMutableArray arrayWithArray:names];
		
		[self executeForAllProperties:^(CKObjectProperty* property,id object){
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
			if([aDecoder containsValueForKey:property.name]){
				id objectFromDecoder = [aDecoder decodeObjectForKey:property.name];
				if([NSObject isKindOf:[objectFromDecoder class] parentType:property.type]){
					[self setValue:objectFromDecoder forKey:property.name];
				}
				else if(objectFromDecoder){
					if(metaData.creatable){
						id p = [self valueForKey:property.name];
						if(p == nil){
							p = [[[property.type alloc]init]autorelease];
							[self setValue:p forKey:property.name];
						}
					}
					[self propertyChanged:property serializedObject:objectFromDecoder];
				}
			}else{
				if(metaData.creatable){
					id p = [self valueForKey:property.name];
					if(p == nil){
						p = [[[property.type alloc]init]autorelease];
						[self setValue:p forKey:property.name];
					}
				}
				
				[self propertyAdded:property];
			}
			
			[allPropertiesInDecoder removeObject:property.name];
		}];
		
		for(NSString* propertyName in allPropertiesInDecoder){
			id objectFromDecoder = [aDecoder decodeObjectForKey:propertyName];
			[self propertyRemoved:propertyName serializedObject:objectFromDecoder];
		}
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	NSAssert([aCoder allowsKeyedCoding],@"NFBModelObject does not support sequential archiving.");
	NSMutableArray* names = [NSMutableArray arrayWithArray:[self allPropertyNames]];
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
		if(metaData.serializable){
			[aCoder encodeObject:object forKey:property.name];
		}
		else{
			[names removeObject:property.name];
		}
	}];
	[aCoder encodeObject:names forKey:CKModelObjectAllPropertyNamesKey];
}

- (BOOL) isEqual:(id)other {
	if ([other isKindOfClass:[self class]]) {
		__block BOOL result = YES;
		[self executeForAllProperties:^(CKObjectProperty* property,id object){
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
			if(metaData.comparable){
				id otherObject = [other valueForKey:property.name];
				BOOL propertyEqual = ((object == nil && otherObject == nil) || [object isEqual:otherObject]);;
				if(!propertyEqual){
					result = NO;
				}
			}
		}];
		return result;
	}
	return NO;
}

- (NSUInteger)hash {
	NSMutableArray* allValues = [NSMutableArray array];
	[self executeForAllProperties:^(CKObjectProperty* property,id object){
		CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
		if(metaData.hashable){
			[allValues addObject:object];
		}
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

//For Migration
- (void)propertyChanged:(CKObjectProperty*)property serializedObject:(id)object{
	NSLog(@"property %@ type %@ found in archive has differs from current property type %@\nDo migration if needed.",property.name,[object className],[property className]);
}

- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object{
	NSLog(@"property %@ in archive disappeard in model object of type %@\nDo migration if needed.",propertyName,[self className]);
}

- (void)propertyAdded:(CKObjectProperty*)property{
	NSLog(@"property %@ not found in archive for object of type %@\nDo migration if needed.",property.name,[self className]);
}

@end