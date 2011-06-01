//
//  CKModelObject.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"
#import <objc/runtime.h>
#import "CKNSObject+Invocation.h"
#import "CKLocalization.h"

static CKModelObjectPropertyMetaData* CKModelObjectPropertyMetaDataSingleton = nil;

@implementation CKModelObjectPropertyMetaData
@synthesize comparable;
@synthesize serializable;
@synthesize creatable;
@synthesize hashable;
@synthesize copiable;
@synthesize deepCopy;
@synthesize editable;
@synthesize enumDefinition;
@synthesize contentType;
@synthesize dateFormat;
@synthesize valuesAndLabels;

- (void)dealloc{
	self.enumDefinition = nil;
	self.dateFormat = nil;
	[super dealloc];
}

- (void)reset{
	self.comparable = YES;
	self.serializable = YES;
	self.creatable = NO;
	self.hashable = YES;
	self.copiable = YES;
	self.deepCopy = NO;
	self.editable = YES;
	self.enumDefinition = nil;
	self.valuesAndLabels = nil;
	self.contentType = nil;
	self.dateFormat = nil;
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

@interface CKModelObject()
- (void)initializeProperties;
- (void)uninitializeProperties;
@end

@implementation CKModelObject


+ (id)model{
	return [[[[self class]alloc]init]autorelease];
}

- (void)postInit{
}


- (void)initializeProperties{
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
			
			SEL changeSelector =  [NSObject selectorForProperty:property.name suffix:@"Changed"];
			if([self respondsToSelector:changeSelector]){
				[self addObserver:self forKeyPath:property.name options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:self];
			}
			else if([NSObject isKindOf:property.type parentType:[NSArray class]] 
			   || [NSObject isKindOf:property.type parentType:[NSSet class]]){
				SEL addsSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsAdded:atIndexes:"];
				SEL removeSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsRemoved:atIndexes:"];
				SEL replaceSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsReplaced:byObjects:atIndexes:"];
				if([self respondsToSelector:addsSelector] || [self respondsToSelector:removeSelector] || [self respondsToSelector:replaceSelector]){
					[self addObserver:self forKeyPath:property.name options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:self];
				}
			}
		}
	}
}


- (void)uninitializeProperties{
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
			
			SEL changeSelector =  [NSObject selectorForProperty:property.name suffix:@"Changed"];
			if([self respondsToSelector:changeSelector]){
				[self removeObserver:self forKeyPath:property.name];
			}
			
			else if([NSObject isKindOf:property.type parentType:[NSArray class]] 
			   || [NSObject isKindOf:property.type parentType:[NSSet class]]){
				SEL addsSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsAdded:atIndexes:"];
				SEL removeSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsRemoved:atIndexes:"];
				SEL replaceSelector =  [NSObject selectorForProperty:property.name suffix:@"ObjectsReplaced:byObjects:atIndexes:"];
				if([self respondsToSelector:addsSelector] || [self respondsToSelector:removeSelector] || [self respondsToSelector:replaceSelector]){
					[self removeObserver:self forKeyPath:property.name];
				}
			}
		}
	}
}

- (id)init{
	[super init];
	[self initializeProperties];
	[self postInit];
	return self;
}

- (void)dealloc{
	[self uninitializeProperties];
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

- (id) copyWithZone:(NSZone *)zone {
	CKModelObject* copied = [[[self class] alloc] init];
	[copied copy:self];
	return copied;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	NSAssert([aDecoder allowsKeyedCoding],@"NFBModelObject does not support sequential archiving.");
    if (self = [super init]) {
		[self initializeProperties];
		[self postInit];
		
		//FUCK names est mal serialize !!!!!!!!!
		NSArray* names = [aDecoder decodeObjectForKey:CKModelObjectAllPropertyNamesKey];
		NSMutableArray* allPropertiesInDecoder = [NSMutableArray arrayWithArray:names];
		
		NSArray* allProperties = [self allPropertyDescriptors];
		for(CKClassPropertyDescriptor* property in allProperties){
			CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:self property:property];
			if(metaData.serializable == YES){
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
		}
			
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

/*
- (BOOL) isEqual:(id)other {
	return self == other;
}
*/

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

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if(object == context && object == self){
		NSIndexSet* indexes = [change objectForKey: NSKeyValueChangeIndexesKey];
		NSArray *oldModels =  [change objectForKey: NSKeyValueChangeOldKey];
		NSArray *newModels =  [change objectForKey: NSKeyValueChangeNewKey];
		
		NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
		switch(kind){
			case NSKeyValueChangeSetting:{
				SEL changeSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"Changed"];
				if([self respondsToSelector:changeSelector]){
					[self performSelector:changeSelector];
				}
				break;
			}
			case NSKeyValueChangeInsertion:{
				SEL addsSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"ObjectsAdded:atIndexes:"];
				if([self respondsToSelector:addsSelector]){
					[self performSelector:addsSelector withObject:newModels withObject:indexes];
				}
				break;
			}
			case NSKeyValueChangeRemoval:{
				SEL removeSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"ObjectsRemoved:atIndexes:"];
				if([self respondsToSelector:removeSelector]){
					[self performSelector:removeSelector withObject:oldModels withObject:indexes];
				}
				break;
			}
			case NSKeyValueChangeReplacement:{
				SEL replaceSelector =  [NSObject selectorForProperty:theKeyPath suffix:@"ObjectsReplaced:byObjects:atIndexes:"];
				if([self respondsToSelector:replaceSelector]){
					[self performSelector:replaceSelector withObjects:[NSArray arrayWithObjects:oldModels,newModels,indexes,nil]];
				}
				break;
			}
		}
	}
}

@end

@implementation NSObject (CKModelObject)

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

- (BOOL)isEqualToObject:(id)other{
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

+ (NSDictionary*)validationPredicates{
	//this can be overloaded in your subclasses to define your own validation predicates
	//example : [NSDictionary dictionaryWithObjectsAndKeys:predicate1,@"propertyName1",predicate2,@"propertyName2",...,nil];
	return [NSDictionary dictionary];
}

- (BOOL)isValid{
	NSDictionary* validation = [[self class]validationPredicates];
	if(validation != nil){
		for(NSString* propertyName in [validation allKeys]){
			id value = [self valueForKeyPath:propertyName];
			NSPredicate* predicate = [validation objectForKey:propertyName];
			if([predicate evaluateWithObject:value] == NO){
				return NO;
			}
		}
	}
	return YES;
}

@end