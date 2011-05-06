//
//  CKModelObject.m
//  CloudKit
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
@synthesize deepCopy;
@synthesize editable;

- (void)reset{
	comparable = YES;
	serializable = YES;
	creatable = NO;
	hashable = YES;
	copiable = YES;
	deepCopy = NO;
	editable = YES;
}

+ (CKModelObjectPropertyMetaData*)propertyMetaDataForObject:(id)object property:(CKClassPropertyDescriptor*)property{
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

- (void)postInit{
}

- (id)init{
	[super init];
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			if(property.propertyType == CKClassPropertyDescriptorTypeObject){
				CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
				if(metaData.creatable){
					id p = [[[property.type alloc]init]autorelease];
					[self setValue:p forKey:property.name];
				}
			}
		}
	}
	
	[self postInit];
	return self;
}

- (void)dealloc{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			if((property.propertyType == CKClassPropertyDescriptorTypeObject) && 
			   ((property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy) || (property.assignementType == CKClassPropertyDescriptorAssignementTypeRetain))) {
				id object = [self valueForKey:property.name];
				if(object){
					[object release];
				}
				//[self setValue:nil forKey:property.name];
			}
		}
	}
	
	[super dealloc];
}

- (NSString*)description{
	NSMutableString* desc = [NSMutableString stringWithFormat:@"%@ : <%p> {\n",[self className],self];
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			id object = [self valueForKey:property.name];
			NSString* propertyString = [NSString stringWithFormat:@"%@ = %@\n",property.name,[object description]];
			[desc appendString:propertyString];
		}
	}
	[desc appendString:@"}"];
	 
	return desc;
}


- (void)copy : (id)other{
	NSArray* allProperties = [other allPropertyDescriptors ];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:other property:property];
			if(metaData.copiable){
				id value = [other valueForKey:property.name];
				if(metaData.deepCopy && property.assignementType != CKClassPropertyDescriptorAssignementTypeCopy){
					if([value isKindOfClass:[NSArray class]]){
						NSArray* array = value;
						value = [[property.type alloc]init];
						for(id object in array){
							[value addObject:[object copy]];
						}
					}
					else if([value isKindOfClass:[NSDictionary class]]){
						NSDictionary* dico = value;
						value = [[property.type alloc]init];
						for(id key in [dico allKeys]){
							id object = [dico objectForKey:key];
							[value setObject:[object copy] forKey:key];
						}
					}
					else if([value isKindOfClass:[NSSet class]]){
						NSMutableSet* set = value;
						value = [[property.type alloc]init];
						for(id object in set){
							[value addObject:[object copy]];
						}
					}
					else{
						value = [value copyWithZone:nil];
					}
					if(property.assignementType == CKClassPropertyDescriptorAssignementTypeCopy
					   || property.assignementType == CKClassPropertyDescriptorAssignementTypeRetain){
						[value autorelease];
					}
				}
				[self setValue:value forKey:property.name];
			}
		}
	}
}

- (id) copyWithZone:(NSZone *)zone {
	CKModelObject* copied = [[[self class] alloc] init];
	[copied copy:self];
	return copied;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	NSAssert([aDecoder allowsKeyedCoding],@"NFBModelObject does not support sequential archiving.");
    self = [super init];
    if (self) {
		//FUCK names est mal serialize !!!!!!!!!
		NSArray* names = [aDecoder decodeObjectForKey:CKModelObjectAllPropertyNamesKey];
		NSMutableArray* allPropertiesInDecoder = [NSMutableArray arrayWithArray:names];
		
		NSArray* allProperties = [self allPropertyDescriptors];
		for(CKClassPropertyDescriptor* property in allProperties){
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
		}
		
		for(NSString* propertyName in allPropertiesInDecoder){
			id objectFromDecoder = [aDecoder decodeObjectForKey:propertyName];
			[self propertyRemoved:propertyName serializedObject:objectFromDecoder];
		}
	}
	[self postInit];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	NSAssert([aCoder allowsKeyedCoding],@"NFBModelObject does not support sequential archiving.");
	NSMutableArray* names = [NSMutableArray arrayWithArray:[self allPropertyNames]];
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			id object = [self valueForKey:property.name];
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
			if(metaData.serializable){
				[aCoder encodeObject:object forKey:property.name];
			}
			else{
				[names removeObject:property.name];
			}
		}
	}
	[aCoder encodeObject:names forKey:CKModelObjectAllPropertyNamesKey];
}

- (BOOL) isEqual:(id)other {
	if ([other isKindOfClass:[self class]]) {
		BOOL result = YES;
		NSArray* allProperties = [self allPropertyDescriptors];
		for(CKClassPropertyDescriptor* property in allProperties){
			if(property.isReadOnly == NO){
				id object = [self valueForKey:property.name];
				CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
				if(metaData.comparable){
					id otherObject = [other valueForKey:property.name];
					BOOL propertyEqual = ((object == nil && otherObject == nil) || [object isEqual:otherObject]);;
					if(!propertyEqual){
						result = NO;
					}
				}
			}
		}
		return result;
	}
	return NO;
}

- (NSUInteger)hash {
	NSMutableArray* allValues = [NSMutableArray array];
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
			id object = [self valueForKey:property.name];
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
			if(object && metaData.hashable){
				[allValues addObject:object];
			}
		}
	}
	return (NSUInteger)[allValues hash];
}


//For Migration
- (void)propertyChanged:(CKClassPropertyDescriptor*)property serializedObject:(id)object{
	NSLog(@"property %@ type %@ found in archive has differs from current property type %@\nDo migration if needed.",property.name,[object className],[property className]);
}

- (void)propertyRemoved:(NSString*)propertyName serializedObject:(id)object{
	NSLog(@"property %@ in archive disappeard in model object of type %@\nDo migration if needed.",propertyName,[self className]);
}

- (void)propertyAdded:(CKClassPropertyDescriptor*)property{
	NSLog(@"property %@ not found in archive for object of type %@\nDo migration if needed.",property.name,[self className]);
}

- (id)valueForUndefinedKey:(NSString *)key{
	return nil;
}

@end